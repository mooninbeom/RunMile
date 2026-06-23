//
//  WorkoutDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit
import CoreData
import MapKit


actor WorkoutDataRepositoryImpl: WorkoutDataRepository {
    private let store = HKHealthStore()
    
    public func fetchAllWorkoutData() async throws -> [Workout] {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let descriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        
        let fetchedResult: [HKWorkout] = try await store.fetchData(
            sampleType: .workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: descriptor
        )
        
        let result = fetchedResult.map {
            Workout(
                workout: $0
            )
        }
        
        return result
    }
    
    func fetchSingleWorkoutData(workout: HKWorkout) async throws -> WorkoutDetailData {
        var result = WorkoutDetailData()
        
        let pace = try await fetchRequiredDetailedWorkoutData(workout: workout, type: .init(.runningSpeed))
        let heartRate = await fetchOptionalDetailedWorkoutData(workout: workout, type: .init(.heartRate))
        let power = await fetchOptionalDetailedWorkoutData(workout: workout, type: .init(.runningPower))
        let cadence = await fetchOptionalDetailedWorkoutData(workout: workout, type: .init(.stepCount))
        let verticalOscillation = await fetchOptionalDetailedWorkoutData(workout: workout, type: .init(.runningVerticalOscillation))
        let groundContactTime = await fetchOptionalDetailedWorkoutData(workout: workout, type: .init(.runningGroundContactTime))
        let strideLength = await fetchOptionalDetailedWorkoutData(workout: workout, type: .init(.runningStrideLength))
        let splits = await fetchOptionalSplits(workout: workout)
        let route = await fetchOptionalWorkoutRouteData(workout: workout)
        
        let unifiedPace = DTOMapper.normalizeData(workout: workout, data: pace)
        let unifiedHeartRate = DTOMapper.normalizeData(workout: workout, data: heartRate)
        let unifiedPower = DTOMapper.normalizeData(workout: workout, data: power)
        let unifiedVerticalOscillation = DTOMapper.normalizeData(workout: workout, data: verticalOscillation)
        let unifiedGroundContactTime = DTOMapper.normalizeData(workout: workout, data: groundContactTime)
        let unifiedStrideLength = DTOMapper.normalizeData(workout: workout, data: strideLength)
        let avgCadence = cadence.reduce(0.0, { $0 + $1.value }) / (workout.duration / 60)
        
        result.heartRate = unifiedHeartRate
        result.runningPace = unifiedPace
        result.power = unifiedPower
        result.cadence = avgCadence
        result.groundContactTime = unifiedGroundContactTime
        result.verticalOscillation = unifiedVerticalOscillation
        result.strideLength = unifiedStrideLength
        result.splits = splits
        result.routes = route
        
        return result
    }
    
    
    func fetchDetailedWorkoutRouteData(workout: HKWorkout) async throws -> [CLLocation] {
        var returnResult: [CLLocation] = []
        
        let routeType = HKSeriesType.workoutRoute()
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        // 경로 객체는 보통 1개지만, 일시정지 등으로 끊기면 여러 개일 수도 있어 sort를 해줍니다.
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let routes: [HKWorkoutRoute] = try await store.fetchData(
            sampleType: routeType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        )
        
        if routes.isEmpty { return [] }
        
        for route in routes {
            let routeResult = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], any Error>) in
                var fetchedLocations: [CLLocation] = []
                
                let locationQuery = HKWorkoutRouteQuery(route: route) { query, locations, done, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                        return
                    }
                    if let locations = locations {
                        fetchedLocations.append(contentsOf: locations)
                    }
                    
                    if done {
                        continuation.resume(returning: fetchedLocations)
                    }
                }
                store.execute(locationQuery)
            }
            
            returnResult.append(contentsOf: routeResult)
        }
        
        return returnResult
    }
    
    func fetchDetailedWorkoutData(workout: HKWorkout, type: HKQuantityType) async throws -> [RunningMetricPoint] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        
        // 기존 store 인스턴스 재사용
        let quantitySamples: [HKQuantitySample] = try await store.fetchData(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        )
        
        var result: [RunningMetricPoint] = []
        
        for sample in quantitySamples {
            if sample.count > 1 {
                let seriesPoints = try await fetchQuantitySeriesPoints(sample: sample, type: type)
                result.append(contentsOf: seriesPoints)
            } else if let point = makeRunningMetricPoint(quantity: sample.quantity, timestamp: sample.startDate, type: type) {
                result.append(point)
            }
        }
        
        let sortedResult = result.sorted { $0.timestamp < $1.timestamp }
        
        #if DEBUG
        logMetricSamples(workout: workout, type: type, samples: quantitySamples, points: sortedResult)
        #endif
        
        return sortedResult
    }
    
    /// 운동 상세의 핵심 metric을 가져오며, 실패 시 상세 화면 전체 실패로 전파합니다.
    private func fetchRequiredDetailedWorkoutData(workout: HKWorkout, type: HKQuantityType) async throws -> [RunningMetricPoint] {
        do {
            return try await fetchDetailedWorkoutData(workout: workout, type: type)
        } catch {
            #if DEBUG
            print("[WorkoutDetail] required metric failed: \(type.identifier), error: \(error.localizedDescription)")
            #endif
            throw error
        }
    }
    
    /// 보조 metric은 기기/운동/권한에 따라 없을 수 있으므로 실패 시 빈 배열로 대체합니다.
    private func fetchOptionalDetailedWorkoutData(workout: HKWorkout, type: HKQuantityType) async -> [RunningMetricPoint] {
        do {
            return try await fetchDetailedWorkoutData(workout: workout, type: type)
        } catch {
            #if DEBUG
            print("[WorkoutDetail] optional metric skipped: \(type.identifier), error: \(error.localizedDescription)")
            #endif
            return []
        }
    }
    
    /// route는 실내 러닝처럼 없는 것이 정상인 운동이 있어 실패 시 빈 배열로 대체합니다.
    private func fetchOptionalWorkoutRouteData(workout: HKWorkout) async -> [CLLocation] {
        do {
            return try await fetchDetailedWorkoutRouteData(workout: workout)
        } catch {
            #if DEBUG
            print("[WorkoutDetail] route skipped: \(error.localizedDescription)")
            #endif
            return []
        }
    }
    
    /// 구간 기록은 보조 정보이므로 거리 샘플 조회 실패 시 상세 로딩을 막지 않습니다.
    private func fetchOptionalSplits(workout: HKWorkout) async -> [SplitInfo] {
        do {
            return try await fetchSplits(workout: workout)
        } catch {
            #if DEBUG
            print("[WorkoutDetail] splits skipped: \(error.localizedDescription)")
            #endif
            return []
        }
    }
    
    public func fetchUnsavedWorkoutData() async throws -> [Workout] {
        let savedWorkouts = try await fetchSavedWorkoutData()
        let entireWorkouts = try await fetchAllWorkoutData()
        
        let result = entireWorkouts.filter { first in
            !savedWorkouts.contains(where: { $0.id == first.id })
        }
        
        return result
    }
    
    public func fetchSavedWorkoutData() async throws -> [Workout] {
        let request: NSFetchRequest<CDWorkoutDTO> = CDWorkoutDTO.fetchRequest()
        let fetchedResults = try CoreDataManager.shared.context.fetch(request)
        
        return try await DTOMapper.CDWorkoutDTOtoEntities(fetchedResults)
    }
    
    public func fetchDistanceSamples(workout: HKWorkout) async throws -> [WorkoutDistanceSample] {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForObjects(from: workout)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let samples: [HKQuantitySample] = try await store.fetchData(
            sampleType: distanceType,
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: [sortDescriptor]
        )
        
        var result: [WorkoutDistanceSample] = []
        
        for sample in samples {
            if sample.count > 1 {
                let seriesSamples = try await fetchQuantitySeriesDistanceSamples(sample: sample, type: distanceType)
                result.append(contentsOf: seriesSamples)
            } else {
                let distance = sample.quantity.doubleValue(for: .meter())
                guard distance > 0 else { continue }
                
                result.append(
                    WorkoutDistanceSample(
                        startDate: sample.startDate,
                        endDate: sample.endDate,
                        distance: distance
                    )
                )
            }
        }
        
        return result.compactMap { sample in
            let startDate = sample.startDate < workout.startDate ? workout.startDate : sample.startDate
            let endDate = sample.endDate > workout.endDate ? workout.endDate : sample.endDate
            
            guard endDate > startDate else { return nil }
            
            let originalDuration = sample.endDate.timeIntervalSince(sample.startDate)
            let overlapDuration = endDate.timeIntervalSince(startDate)
            let distance: Double
            
            if originalDuration > 0 {
                distance = sample.distance * min(overlapDuration / originalDuration, 1)
            } else {
                distance = sample.distance
            }
            
            guard distance > 0 else { return nil }
            
            return WorkoutDistanceSample(
                startDate: startDate,
                endDate: endDate,
                distance: distance
            )
        }
        .sorted { $0.startDate < $1.startDate }
    }
    
    public func fetchSplits(workout: HKWorkout) async throws -> [SplitInfo] {
        // 1. 거리 데이터 가져오기 (시간순 정렬 필수)
        let samples = try await fetchDistanceSamples(workout: workout)
        
        // 2. 일시정지 구간(Pause Intervals) 미리 계산
        let pauseIntervals = getPauseIntervals(workout: workout)
        
        var splits: [SplitInfo] = []
        var currentKm = 1
        var accumulatedDistance = 0.0
        var lastSplitTime = workout.startDate
        
        // 3. 샘플 순회
        for sample in samples {
            let sampleDistance = sample.distance
            let startDistance = accumulatedDistance
            let endDistance = accumulatedDistance + sampleDistance
            
            // 샘플 구간 안에 타겟(1km, 2km...)이 포함되어 있는지 확인
            while endDistance >= Double(currentKm * 1000) {
                let targetDistance = Double(currentKm * 1000)
                
                // 보간법(Interpolation): 정확히 1000m가 되는 시점을 추정
                // 공식: 시작시간 + (전체시간 * (남은거리 / 전체거리))
                let progress = (targetDistance - startDistance) / (endDistance - startDistance)
                let sampleDuration = sample.endDate.timeIntervalSince(sample.startDate)
                let interpolatedTimeOffset = sampleDuration * progress
                let splitPassTime = sample.startDate.addingTimeInterval(interpolatedTimeOffset)
                
                // 순수 운동 시간 계산 (일시정지 제외)
                let activeDuration = self.calculateActiveDuration(start: lastSplitTime, end: splitPassTime, pauses: pauseIntervals)
                
                // 페이스 문자열 변환
                let minutes = Int(activeDuration) / 60
                let seconds = Int(activeDuration) % 60
                let paceString = String(format: "%d'%02d\"", minutes, seconds)
                
                splits.append(SplitInfo(
                    label: String(currentKm),
                    duration: activeDuration,
                    pace: paceString
                ))
                
                currentKm += 1
                lastSplitTime = splitPassTime
            }
            
            accumulatedDistance += sampleDistance
        }
        
        // 4. 마지막 자투리 구간(Remainder) 처리
        // 예: 5.3km 뛰었으면 나머지 0.3km에 대한 페이스 정보
        let remainderDistance = accumulatedDistance - Double((currentKm - 1) * 1000)
        
        // 최소 10미터 이상일 때만 기록 (노이즈 방지)
        if remainderDistance > 10 {
            let finalEndTime = samples.last?.endDate ?? workout.endDate
            let activeDuration = self.calculateActiveDuration(start: lastSplitTime, end: finalEndTime, pauses: pauseIntervals)
            
            // 1km 환산 페이스로 변환해서 보여줌 (옵션)
            // 환산 안하고 그냥 시간만 보여주려면 activeDuration 그대로 사용
            let projectedPaceSeconds = activeDuration * (1000.0 / remainderDistance)
            
            let minutes = Int(projectedPaceSeconds) / 60
            let seconds = Int(projectedPaceSeconds) % 60
            let paceString = String(format: "%d'%02d\"", minutes, seconds)
            
            let totalKmLabel = String(format: "%.2f", accumulatedDistance / 1000.0)
            
            splits.append(SplitInfo(
                label: totalKmLabel, // 마지막 구간은 총 거리로 표시 (예: "12.34")
                duration: activeDuration,
                pace: paceString // 여기서는 '구간 페이스'를 기록
            ))
        }
        
        return splits
    }
    
    // MARK: - Helper Methods
    
    /// 워크아웃 이벤트에서 일시정지 구간 추출
    private func getPauseIntervals(workout: HKWorkout) -> [DateInterval] {
        guard let events = workout.workoutEvents else { return [] }
        var pauses: [DateInterval] = []
        var pauseStart: Date?
        
        for event in events {
            if event.type == .pause {
                pauseStart = event.dateInterval.start
            } else if event.type == .resume, let start = pauseStart {
                let end = event.dateInterval.start
                if end > start {
                    pauses.append(DateInterval(start: start, end: end))
                }
                pauseStart = nil
            }
        }
        return pauses
    }
    
    /// 시작~종료 시간 사이에서 일시정지 시간을 뺀 '순수 운동 시간' 계산
    private func calculateActiveDuration(start: Date, end: Date, pauses: [DateInterval]) -> TimeInterval {
        guard end > start else { return 0 }
        
        var duration = end.timeIntervalSince(start)
        let totalRange = DateInterval(start: start, end: end)
        
        for pause in pauses {
            // 스플릿 구간과 겹치는 일시정지 시간만큼 차감
            if let intersection = totalRange.intersection(with: pause) {
                duration -= intersection.duration
            }
        }
        
        return max(duration, 0)
    }
    
    private func fetchQuantitySeriesDistanceSamples(sample: HKQuantitySample, type: HKQuantityType) async throws -> [WorkoutDistanceSample] {
        let predicate = HKQuery.predicateForObject(with: sample.uuid)
        
        return try await withCheckedThrowingContinuation { continuation in
            var samples: [WorkoutDistanceSample] = []
            
            let query = HKQuantitySeriesSampleQuery(quantityType: type, predicate: predicate) { _, quantity, dateInterval, _, done, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let quantity,
                   let dateInterval {
                    let distance = quantity.doubleValue(for: .meter())
                    if distance > 0 {
                        samples.append(
                            WorkoutDistanceSample(
                                startDate: dateInterval.start,
                                endDate: dateInterval.end,
                                distance: distance
                            )
                        )
                    }
                }
                
                if done {
                    continuation.resume(returning: samples)
                }
            }
            
            store.execute(query)
        }
    }
    
    private func fetchQuantitySeriesPoints(sample: HKQuantitySample, type: HKQuantityType) async throws -> [RunningMetricPoint] {
        let predicate = HKQuery.predicateForObject(with: sample.uuid)
        
        return try await withCheckedThrowingContinuation { continuation in
            var points: [RunningMetricPoint] = []
            
            let query = HKQuantitySeriesSampleQuery(quantityType: type, predicate: predicate) { [weak self] _, quantity, dateInterval, _, done, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                if let quantity,
                   let dateInterval,
                   let point = self?.makeRunningMetricPoint(quantity: quantity, timestamp: dateInterval.start, type: type) {
                    points.append(point)
                }
                
                if done {
                    continuation.resume(returning: points)
                }
            }
            
            store.execute(query)
        }
    }
    
    nonisolated private func makeRunningMetricPoint(quantity: HKQuantity, timestamp: Date, type: HKQuantityType) -> RunningMetricPoint? {
        let value: Double
        let unit: String
        
        switch type.identifier {
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            value = quantity.doubleValue(for: .count().unitDivided(by: .minute()))
            unit = "BPM"
        case HKQuantityTypeIdentifier.runningSpeed.rawValue:
            value = quantity.doubleValue(for: .meter().unitDivided(by: .second()))
            unit = "m/s"
        case HKQuantityTypeIdentifier.runningPower.rawValue:
            value = quantity.doubleValue(for: .watt())
            unit = "W"
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            value = quantity.doubleValue(for: .count())
            unit = "Count"
        case HKQuantityTypeIdentifier.runningVerticalOscillation.rawValue:
            value = quantity.doubleValue(for: .meterUnit(with: .centi))
            unit = "cm"
        case HKQuantityTypeIdentifier.runningGroundContactTime.rawValue:
            value = quantity.doubleValue(for: .secondUnit(with: .milli))
            unit = "ms"
        case HKQuantityTypeIdentifier.runningStrideLength.rawValue:
            value = quantity.doubleValue(for: .meter())
            unit = "m"
        default:
            return nil
        }
        
        return .init(timestamp: timestamp, value: value, unit: unit)
    }
}

#if DEBUG
private extension WorkoutDataRepositoryImpl {
    func logMetricSamples(
        workout: HKWorkout,
        type: HKQuantityType,
        samples: [HKQuantitySample],
        points: [RunningMetricPoint]
    ) {
        let sortedSamples = samples.sorted { $0.startDate < $1.startDate }
        let sortedPoints = points.sorted { $0.timestamp < $1.timestamp }
        let sampleGaps = zip(sortedSamples, sortedSamples.dropFirst())
            .map { $1.startDate.timeIntervalSince($0.startDate) }
            .filter { $0 >= 0 }
        let pointGaps = zip(sortedPoints, sortedPoints.dropFirst())
            .map { $1.timestamp.timeIntervalSince($0.timestamp) }
            .filter { $0 >= 0 }
        let sampleCounts = sortedSamples.map(\.count)
        let compressedSampleCount = sampleCounts.filter { $0 > 1 }.count
        
        let metricName = readableMetricName(for: type)
        let workoutStart = Self.metricLogDateFormatter.string(from: workout.startDate)
        let workoutEnd = Self.metricLogDateFormatter.string(from: workout.endDate)
        
        print("""
        [WorkoutMetricLog] \(metricName)
        - workout: \(workout.uuid.uuidString)
        - workoutTime: \(workoutStart) ~ \(workoutEnd) / duration: \(formatSeconds(workout.duration))
        - rawSampleCount: \(sortedSamples.count), compressedSampleCount: \(compressedSampleCount), expandedPointCount: \(sortedPoints.count)
        - rawSampleInnerCounts: \(sampleCountSummary(sampleCounts))
        - rawSampleRange: \(dateRangeDescription(sortedSamples.map(\.startDate)))
        - rawSampleGaps: \(gapSummary(sampleGaps))
        - expandedPointGaps: \(gapSummary(pointGaps))
        - firstSamples:
        \(samplePreview(sortedSamples.prefix(8).map { ($0.startDate, valueDescription(for: $0, type: type)) }))
        - lastSamples:
        \(samplePreview(sortedSamples.suffix(8).map { ($0.startDate, valueDescription(for: $0, type: type)) }))
        """)
    }
    
    func readableMetricName(for type: HKQuantityType) -> String {
        switch type.identifier {
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            return "heartRate"
        case HKQuantityTypeIdentifier.runningSpeed.rawValue:
            return "runningSpeed"
        case HKQuantityTypeIdentifier.runningPower.rawValue:
            return "runningPower"
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            return "stepCount"
        case HKQuantityTypeIdentifier.runningVerticalOscillation.rawValue:
            return "runningVerticalOscillation"
        case HKQuantityTypeIdentifier.runningGroundContactTime.rawValue:
            return "runningGroundContactTime"
        case HKQuantityTypeIdentifier.runningStrideLength.rawValue:
            return "runningStrideLength"
        default:
            return type.identifier
        }
    }
    
    func valueDescription(for sample: HKQuantitySample, type: HKQuantityType) -> String {
        let value: Double
        let unit: String
        
        switch type.identifier {
        case HKQuantityTypeIdentifier.heartRate.rawValue:
            value = sample.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
            unit = "BPM"
        case HKQuantityTypeIdentifier.runningSpeed.rawValue:
            value = sample.quantity.doubleValue(for: .meter().unitDivided(by: .second()))
            unit = "m/s"
        case HKQuantityTypeIdentifier.runningPower.rawValue:
            value = sample.quantity.doubleValue(for: .watt())
            unit = "W"
        case HKQuantityTypeIdentifier.stepCount.rawValue:
            value = sample.quantity.doubleValue(for: .count())
            unit = "count"
        case HKQuantityTypeIdentifier.runningVerticalOscillation.rawValue:
            value = sample.quantity.doubleValue(for: .meterUnit(with: .centi))
            unit = "cm"
        case HKQuantityTypeIdentifier.runningGroundContactTime.rawValue:
            value = sample.quantity.doubleValue(for: .secondUnit(with: .milli))
            unit = "ms"
        case HKQuantityTypeIdentifier.runningStrideLength.rawValue:
            value = sample.quantity.doubleValue(for: .meter())
            unit = "m"
        default:
            value = sample.quantity.doubleValue(for: .count())
            unit = "count"
        }
        
        return "\(String(format: "%.2f", value)) \(unit)"
    }
    
    func dateRangeDescription(_ dates: [Date]) -> String {
        guard let first = dates.first, let last = dates.last else {
            return "empty"
        }
        
        return "\(Self.metricLogDateFormatter.string(from: first)) ~ \(Self.metricLogDateFormatter.string(from: last))"
    }
    
    func gapSummary(_ gaps: [TimeInterval]) -> String {
        guard !gaps.isEmpty else {
            return "not enough samples"
        }
        
        let sortedGaps = gaps.sorted()
        let minGap = sortedGaps.first ?? 0
        let medianGap = sortedGaps[sortedGaps.count / 2]
        let maxGap = sortedGaps.last ?? 0
        let over30Count = sortedGaps.filter { $0 > 30 }.count
        let over60Count = sortedGaps.filter { $0 > 60 }.count
        
        return "min \(formatSeconds(minGap)), median \(formatSeconds(medianGap)), max \(formatSeconds(maxGap)), >30s \(over30Count), >60s \(over60Count)"
    }
    
    func sampleCountSummary(_ counts: [Int]) -> String {
        guard !counts.isEmpty else {
            return "empty"
        }
        
        let sortedCounts = counts.sorted()
        let minCount = sortedCounts.first ?? 0
        let medianCount = sortedCounts[sortedCounts.count / 2]
        let maxCount = sortedCounts.last ?? 0
        
        return "min \(minCount), median \(medianCount), max \(maxCount)"
    }
    
    func samplePreview(_ samples: [(Date, String)]) -> String {
        guard !samples.isEmpty else {
            return "  empty"
        }
        
        return samples
            .map { date, value in
                "  \(Self.metricLogDateFormatter.string(from: date)) / \(value)"
            }
            .joined(separator: "\n")
    }
    
    func formatSeconds(_ seconds: TimeInterval) -> String {
        String(format: "%.1fs", seconds)
    }
    
    static var metricLogDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }
}
#endif

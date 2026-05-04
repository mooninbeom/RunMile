//
//  WorkoutDetailUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 12/23/25.
//

import Foundation
import HealthKit
import CoreLocation

protocol WorkoutDetailUseCase: Sendable {
    /// 특정 운동의 전체 세부 데이터를 받아옵니다.
    func fetchWorkoutDetailData(workout: Workout, samplingCount: Int) async throws -> WorkoutDetailData
    
    /// 내부 메소드, 다운 샘플링을 진행합니다. (한정된 디스플레이 내에서의 표시를 위해)
    func downsampling(samples: [UnifiedWorkoutDetailData], targetCount: Int) -> [UnifiedWorkoutDetailData]
    
    /// 운동 경로를 지도 표시용 페이스 구간으로 변환합니다.
    func buildRouteSegments(locations: [CLLocation], runningPace: [UnifiedWorkoutDetailData], workoutStartDate: Date) -> [WorkoutRouteSegment]
}



final class DefaultWorkoutDetailUseCase: WorkoutDetailUseCase {
    func fetchWorkoutDetailData(workout: Workout, samplingCount: Int) async throws -> WorkoutDetailData {
        var result = try await workoutRepository.fetchSingleWorkoutData(workout: workout.workout)
        
        if samplingCount == 0 {
            result.routeSegments = self.buildRouteSegments(
                locations: result.routes,
                runningPace: result.runningPace,
                workoutStartDate: workout.workout.startDate
            )
            return result
        }
        
        result.heartRate = self.downsampling(samples: result.heartRate, targetCount: samplingCount)
        result.runningPace = self.downsampling(samples: result.runningPace, targetCount: samplingCount)
        result.power = self.downsampling(samples: result.power, targetCount: samplingCount)
        result.groundContactTime = self.downsampling(samples: result.groundContactTime, targetCount: samplingCount)
        result.strideLength = self.downsampling(samples: result.strideLength, targetCount: samplingCount)
        result.verticalOscillation = self.downsampling(samples: result.verticalOscillation, targetCount: samplingCount)
        result.routeSegments = self.buildRouteSegments(
            locations: result.routes,
            runningPace: result.runningPace,
            workoutStartDate: workout.workout.startDate
        )
        
        return result
    }
    
    func downsampling(samples: [UnifiedWorkoutDetailData], targetCount: Int) -> [UnifiedWorkoutDetailData] {
        // 데이터가 목표보다 적으면 그냥 원본 반환 (짧은 러닝)
        if samples.count <= targetCount {
            return samples
        }

        var result: [UnifiedWorkoutDetailData] = []

        // 묶음 크기 계산 (예: 3600개 / 100개 = 36개씩 묶자)
        let bucketSize = samples.count / targetCount

        // stride를 이용해 구간별로 순회
        for i in stride(from: 0, to: samples.count, by: bucketSize) {
            // 범위 안전하게 자르기
            let end = Swift.min(i + bucketSize, samples.count)
            let chunk = samples[i..<end]

            // --- 구간 평균 계산 (핵심) ---

            // 1. 시간: 구간의 시작 시간 or 중간 시간
            let representTime = chunk.first?.date ?? Date()
            let representSeconds = chunk.first?.seconds ?? 0

            // 2. 심박수: 구간 평균
            // nil이 아닌 값들만 골라서 평균 계산
            let validValue = chunk.compactMap { $0.value }
            let avgValue = validValue.isEmpty ? nil : validValue.reduce(0, +) / Double(validValue.count)

            // 4. 새로운 '대표 점' 생성
            let point = UnifiedWorkoutDetailData(
                seconds: representSeconds,
                date: representTime,
                value: avgValue
            )

            result.append(point)
        }

        return result
    }
    
    func buildRouteSegments(
        locations: [CLLocation],
        runningPace: [UnifiedWorkoutDetailData],
        workoutStartDate: Date
    ) -> [WorkoutRouteSegment] {
        let cleanedLocations = cleanRouteLocations(locations)
        let smoothedLocations = smoothLocations(cleanedLocations)
        let simplifiedLocations = simplifyLocations(smoothedLocations, tolerance: 7, maxPointCount: 700)
        let validPacePoints = runningPace.compactMap { point -> (seconds: Int, speed: Double)? in
            guard let value = point.value,
                  value.isFinite,
                  value > 0 else {
                return nil
            }
            
            return (seconds: point.seconds, speed: value)
        }
        
        guard simplifiedLocations.count >= 2,
              !validPacePoints.isEmpty else {
            return []
        }
        
        let segmentCandidates = zip(simplifiedLocations, simplifiedLocations.dropFirst()).compactMap { start, end -> (CLLocation, CLLocation, Double)? in
            let seconds = end.timestamp.timeIntervalSince(start.timestamp)
            guard seconds > 0 else { return nil }
            
            let distance = end.distance(from: start)
            guard distance >= 1 else { return nil }
            
            let segmentMidDate = start.timestamp.addingTimeInterval(seconds / 2)
            let segmentMidSeconds = Int(segmentMidDate.timeIntervalSince(workoutStartDate))
            guard let speed = closestPaceSpeed(in: validPacePoints, at: segmentMidSeconds) else {
                return nil
            }
            
            return (start, end, speed)
        }
        
        guard !segmentCandidates.isEmpty else {
            return []
        }
        
        let correctionRange = routePaceCorrectionRange(speeds: segmentCandidates.map(\.2))
        let correctedSpeeds = segmentCandidates.map { _, _, speed in
            correctedRouteSpeed(speed, correctionRange: correctionRange)
        }
        let speedRange = routeSpeedRange(speeds: correctedSpeeds)
        
        return segmentCandidates.map { start, end, speed in
            let correctedSpeed = correctedRouteSpeed(speed, correctionRange: correctionRange)
            
            return WorkoutRouteSegment(
                coordinates: [start.coordinate, end.coordinate],
                averageSpeed: correctedSpeed,
                paceRatio: paceRatio(speed: correctedSpeed, speedRange: speedRange)
            )
        }
    }
    
    private let workoutRepository: WorkoutDataRepository
    
    init(workoutRepository: WorkoutDataRepository) {
        self.workoutRepository = workoutRepository
    }
}


// MARK: - Route Processing
private extension DefaultWorkoutDetailUseCase {
    func cleanRouteLocations(_ locations: [CLLocation]) -> [CLLocation] {
        let sortedLocations = locations.sorted { $0.timestamp < $1.timestamp }
        var result: [CLLocation] = []
        
        for location in sortedLocations {
            guard location.horizontalAccuracy >= 0,
                  location.horizontalAccuracy <= 50 else {
                continue
            }
            
            guard let previous = result.last else {
                result.append(location)
                continue
            }
            
            let seconds = location.timestamp.timeIntervalSince(previous.timestamp)
            guard seconds > 0 else { continue }
            
            let distance = location.distance(from: previous)
            let speed = distance / seconds
            
            if distance < 2 && seconds < 5 {
                continue
            }
            
            if speed > 10 && distance > 20 {
                continue
            }
            
            result.append(location)
        }
        
        return result
    }
    
    func smoothLocations(_ locations: [CLLocation]) -> [CLLocation] {
        guard locations.count > 3 else {
            return locations
        }
        
        return locations.indices.map { index in
            guard index != locations.startIndex,
                  index != locations.index(before: locations.endIndex) else {
                return locations[index]
            }
            
            let previous = locations[locations.index(before: index)]
            let current = locations[index]
            let next = locations[locations.index(after: index)]
            let latitude = (previous.coordinate.latitude + current.coordinate.latitude + next.coordinate.latitude) / 3
            let longitude = (previous.coordinate.longitude + current.coordinate.longitude + next.coordinate.longitude) / 3
            
            return CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                altitude: current.altitude,
                horizontalAccuracy: current.horizontalAccuracy,
                verticalAccuracy: current.verticalAccuracy,
                timestamp: current.timestamp
            )
        }
    }
    
    func simplifyLocations(_ locations: [CLLocation], tolerance: CLLocationDistance, maxPointCount: Int) -> [CLLocation] {
        guard locations.count > 2 else {
            return locations
        }
        
        let simplifiedLocations = douglasPeucker(locations, tolerance: tolerance)
        
        guard simplifiedLocations.count > maxPointCount else {
            return simplifiedLocations
        }
        
        let strideSize = max(1, simplifiedLocations.count / maxPointCount)
        var result = simplifiedLocations.enumerated().compactMap { index, location in
            index % strideSize == 0 ? location : nil
        }
        
        if result.last?.timestamp != simplifiedLocations.last?.timestamp,
           let lastLocation = simplifiedLocations.last {
            result.append(lastLocation)
        }
        
        return result
    }
    
    func douglasPeucker(_ locations: [CLLocation], tolerance: CLLocationDistance) -> [CLLocation] {
        guard locations.count > 2 else {
            return locations
        }
        
        let firstLocation = locations[0]
        let lastLocation = locations[locations.count - 1]
        var maxDistance: CLLocationDistance = 0
        var maxIndex = 0
        
        for index in 1..<(locations.count - 1) {
            let distance = perpendicularDistance(
                from: locations[index],
                toLineStart: firstLocation,
                lineEnd: lastLocation
            )
            
            if distance > maxDistance {
                maxDistance = distance
                maxIndex = index
            }
        }
        
        guard maxDistance > tolerance else {
            return [firstLocation, lastLocation]
        }
        
        let leftLocations = douglasPeucker(Array(locations[0...maxIndex]), tolerance: tolerance)
        let rightLocations = douglasPeucker(Array(locations[maxIndex...(locations.count - 1)]), tolerance: tolerance)
        
        return leftLocations.dropLast() + rightLocations
    }
    
    func perpendicularDistance(from point: CLLocation, toLineStart start: CLLocation, lineEnd end: CLLocation) -> CLLocationDistance {
        let origin = start.coordinate
        let pointVector = projectedPoint(point.coordinate, origin: origin)
        let startVector = projectedPoint(start.coordinate, origin: origin)
        let endVector = projectedPoint(end.coordinate, origin: origin)
        let lineX = endVector.x - startVector.x
        let lineY = endVector.y - startVector.y
        let lineLengthSquared = lineX * lineX + lineY * lineY
        
        guard lineLengthSquared > 0 else {
            return point.distance(from: start)
        }
        
        let progress = max(0, min(1, ((pointVector.x - startVector.x) * lineX + (pointVector.y - startVector.y) * lineY) / lineLengthSquared))
        let projectedX = startVector.x + progress * lineX
        let projectedY = startVector.y + progress * lineY
        let distanceX = pointVector.x - projectedX
        let distanceY = pointVector.y - projectedY
        
        return sqrt(distanceX * distanceX + distanceY * distanceY)
    }
    
    func projectedPoint(_ coordinate: CLLocationCoordinate2D, origin: CLLocationCoordinate2D) -> (x: Double, y: Double) {
        let metersPerDegreeLatitude = 111_320.0
        let metersPerDegreeLongitude = metersPerDegreeLatitude * cos(origin.latitude * .pi / 180)
        
        return (
            x: (coordinate.longitude - origin.longitude) * metersPerDegreeLongitude,
            y: (coordinate.latitude - origin.latitude) * metersPerDegreeLatitude
        )
    }
    
    func routeSpeedRange(speeds: [Double]) -> (slow: Double, fast: Double) {
        let sortedSpeeds = speeds.sorted()
        
        guard !sortedSpeeds.isEmpty else {
            return (slow: 0, fast: 0)
        }
        
        let slowIndex = max(0, Int(Double(sortedSpeeds.count - 1) * 0.10))
        let fastIndex = min(sortedSpeeds.count - 1, Int(Double(sortedSpeeds.count - 1) * 0.90))
        
        return (slow: sortedSpeeds[slowIndex], fast: sortedSpeeds[fastIndex])
    }
    
    func routePaceCorrectionRange(speeds: [Double]) -> (lowerBound: Double, upperBound: Double) {
        // Keep route coloring in a realistic running range: about 16'40"/km to 2'46"/km.
        let plausibleSpeeds = speeds.filter { speed in
            speed >= 1.0 && speed <= 6.0
        }
        
        guard plausibleSpeeds.count >= 5 else {
            return (lowerBound: 1.0, upperBound: 6.0)
        }
        
        let sortedSpeeds = plausibleSpeeds.sorted()
        let q1 = percentile(sortedValues: sortedSpeeds, percentile: 0.25)
        let q3 = percentile(sortedValues: sortedSpeeds, percentile: 0.75)
        let iqr = q3 - q1
        
        guard iqr > 0 else {
            return (lowerBound: 1.0, upperBound: 6.0)
        }
        
        let lowerBound = max(1.0, q1 - (iqr * 1.5))
        let upperBound = min(6.0, q3 + (iqr * 1.5))
        
        return (lowerBound: lowerBound, upperBound: upperBound)
    }
    
    func correctedRouteSpeed(_ speed: Double, correctionRange: (lowerBound: Double, upperBound: Double)) -> Double {
        min(max(speed, correctionRange.lowerBound), correctionRange.upperBound)
    }
    
    func closestPaceSpeed(in pacePoints: [(seconds: Int, speed: Double)], at seconds: Int) -> Double? {
        pacePoints.min {
            abs($0.seconds - seconds) < abs($1.seconds - seconds)
        }?.speed
    }
    
    func percentile(sortedValues: [Double], percentile: Double) -> Double {
        guard !sortedValues.isEmpty else {
            return 0
        }
        
        guard sortedValues.count > 1 else {
            return sortedValues[0]
        }
        
        let clampedPercentile = min(max(percentile, 0), 1)
        let position = clampedPercentile * Double(sortedValues.count - 1)
        let lowerIndex = Int(floor(position))
        let upperIndex = Int(ceil(position))
        
        guard lowerIndex != upperIndex else {
            return sortedValues[lowerIndex]
        }
        
        let weight = position - Double(lowerIndex)
        return sortedValues[lowerIndex] + ((sortedValues[upperIndex] - sortedValues[lowerIndex]) * weight)
    }
    
    func paceRatio(speed: Double, speedRange: (slow: Double, fast: Double)) -> Double {
        guard speedRange.fast > speedRange.slow else {
            return 0
        }
        
        let clampedSpeed = min(max(speed, speedRange.slow), speedRange.fast)
        return 1 - ((clampedSpeed - speedRange.slow) / (speedRange.fast - speedRange.slow))
    }
}

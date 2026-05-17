//
//  HOFUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import Foundation
import HealthKit


protocol HOFUseCase: Sendable {
    func fetchShoes() async throws -> [Shoes]
    func fetchAllRunningWorkouts() async throws -> [Workout]
    func fetchDistanceRecords(for workouts: [Workout]) async -> [WorkoutDistanceRecord]
}


final class DefaultHOFUseCase: HOFUseCase {
    private let repository: ShoesDataRepository
    private let workoutRepository: WorkoutDataRepository
    private let distanceRecordCacheRepository: WorkoutDistanceRecordCacheRepository
    
    init(
        repository: ShoesDataRepository,
        workoutRepository: WorkoutDataRepository,
        distanceRecordCacheRepository: WorkoutDistanceRecordCacheRepository
    ) {
        self.repository = repository
        self.workoutRepository = workoutRepository
        self.distanceRecordCacheRepository = distanceRecordCacheRepository
    }
    
    func fetchShoes() async throws -> [Shoes] {
        try await repository.fetchHOFShoes()
    }
    
    func fetchAllRunningWorkouts() async throws -> [Workout] {
        try await workoutRepository.fetchAllWorkoutData()
    }
    
    func fetchDistanceRecords(for workouts: [Workout]) async -> [WorkoutDistanceRecord] {
        var records: [WorkoutDistanceRecord] = []
        
        for workout in recordEligibleWorkouts(workouts) {
            if let cachedRecords = await distanceRecordCacheRepository.fetchRecords(for: workout) {
                records.append(contentsOf: cachedRecords)
                continue
            }
            
            do {
                let samples = try await workoutRepository.fetchDistanceSamples(workout: workout.workout)
                let calculatedRecords = makeDistanceRecords(workout: workout, samples: samples)
                await distanceRecordCacheRepository.saveRecords(calculatedRecords, for: workout)
                records.append(contentsOf: calculatedRecords)
            } catch {
                #if DEBUG
                print("[HOFReport] distance record skipped: \(workout.id), error: \(error.localizedDescription)")
                #endif
            }
        }
        
        return records
    }
}


private extension DefaultHOFUseCase {
    struct DistanceRecordSegment {
        let startDistance: Double
        let endDistance: Double
        let startActiveDuration: TimeInterval
        let endActiveDuration: TimeInterval
        let startDate: Date
        let endDate: Date
    }
    
    struct DistanceRecordPoint {
        let activeDuration: TimeInterval
        let date: Date
    }
    
    func makeDistanceRecords(workout: Workout, samples: [WorkoutDistanceSample]) -> [WorkoutDistanceRecord] {
        let segments = makeDistanceSegments(workout: workout, samples: samples)
        
        return WorkoutDistanceRecordTarget.allCases.compactMap { target in
            bestRecord(for: target, workout: workout, segments: segments)
        }
    }
    
    func makeDistanceSegments(workout: Workout, samples: [WorkoutDistanceSample]) -> [DistanceRecordSegment] {
        let pauseIntervals = pauseIntervals(for: workout.workout)
        var accumulatedDistance = 0.0
        var segments: [DistanceRecordSegment] = []
        
        for sample in samples.sorted(by: { $0.startDate < $1.startDate }) {
            let sampleStartDate = sample.startDate < workout.workout.startDate ? workout.workout.startDate : sample.startDate
            let sampleEndDate = sample.endDate > workout.workout.endDate ? workout.workout.endDate : sample.endDate
            
            guard sample.distance > 0,
                  sampleEndDate > sampleStartDate else {
                continue
            }
            
            let originalDuration = sample.endDate.timeIntervalSince(sample.startDate)
            let overlapDuration = sampleEndDate.timeIntervalSince(sampleStartDate)
            let adjustedDistance: Double
            
            if originalDuration > 0 {
                adjustedDistance = sample.distance * min(overlapDuration / originalDuration, 1)
            } else {
                adjustedDistance = sample.distance
            }
            
            guard adjustedDistance > 0 else { continue }
            
            let startActiveDuration = activeDuration(
                from: workout.workout.startDate,
                to: sampleStartDate,
                pauses: pauseIntervals
            )
            let endActiveDuration = activeDuration(
                from: workout.workout.startDate,
                to: sampleEndDate,
                pauses: pauseIntervals
            )
            
            guard endActiveDuration > startActiveDuration else {
                continue
            }
            
            let startDistance = accumulatedDistance
            let endDistance = accumulatedDistance + adjustedDistance
            
            segments.append(
                DistanceRecordSegment(
                    startDistance: startDistance,
                    endDistance: endDistance,
                    startActiveDuration: startActiveDuration,
                    endActiveDuration: endActiveDuration,
                    startDate: sampleStartDate,
                    endDate: sampleEndDate
                )
            )
            
            accumulatedDistance = endDistance
        }
        
        return segments
    }
    
    func bestRecord(
        for target: WorkoutDistanceRecordTarget,
        workout: Workout,
        segments: [DistanceRecordSegment]
    ) -> WorkoutDistanceRecord? {
        guard let totalDistance = segments.last?.endDistance,
              totalDistance >= target.meters else {
            return nil
        }
        
        var bestRecord: WorkoutDistanceRecord?
        let startDistances = candidateStartDistances(
            for: target.meters,
            totalDistance: totalDistance,
            segments: segments
        )
        
        for startDistance in startDistances {
            let endDistance = startDistance + target.meters
            guard let startPoint = point(at: startDistance, in: segments),
                  let endPoint = point(at: endDistance, in: segments) else {
                continue
            }
            
            let duration = endPoint.activeDuration - startPoint.activeDuration
            guard duration > 0, duration.isFinite else { continue }
            
            let candidate = WorkoutDistanceRecord(
                workoutID: workout.id,
                target: target,
                duration: duration,
                workoutDate: workout.date,
                segmentStartDate: startPoint.date,
                segmentEndDate: endPoint.date,
                sourceWorkoutDistance: workout.distance
            )
            
            if let currentBest = bestRecord {
                if candidate.duration < currentBest.duration {
                    bestRecord = candidate
                }
            } else {
                bestRecord = candidate
            }
        }
        
        return bestRecord
    }
    
    /// 시작점 또는 종료점이 샘플 경계에 걸리는 후보를 모두 만들어 최고 구간 누락을 줄입니다.
    func candidateStartDistances(
        for targetDistance: Double,
        totalDistance: Double,
        segments: [DistanceRecordSegment]
    ) -> [Double] {
        var startDistances: [Double] = []
        
        for segment in segments {
            if segment.startDistance + targetDistance <= totalDistance {
                startDistances.append(segment.startDistance)
            }
            
            let startDistanceForSegmentEnd = segment.endDistance - targetDistance
            if startDistanceForSegmentEnd >= 0,
               startDistanceForSegmentEnd + targetDistance <= totalDistance {
                startDistances.append(startDistanceForSegmentEnd)
            }
        }
        
        return startDistances
    }
    
    /// 누적 거리 지점이 포함된 샘플 구간을 이진 탐색으로 찾아 시간 좌표를 보간합니다.
    func point(at distance: Double, in segments: [DistanceRecordSegment]) -> DistanceRecordPoint? {
        guard let firstSegment = segments.first,
              let lastSegment = segments.last,
              distance >= firstSegment.startDistance,
              distance <= lastSegment.endDistance else {
            return nil
        }
        
        var lowerBound = 0
        var upperBound = segments.count - 1
        
        while lowerBound < upperBound {
            let middle = (lowerBound + upperBound) / 2
            
            if segments[middle].endDistance < distance {
                lowerBound = middle + 1
            } else {
                upperBound = middle
            }
        }
        
        let segment = segments[lowerBound]
        guard distance >= segment.startDistance,
              distance <= segment.endDistance else {
            return nil
        }
        
        let distanceDelta = segment.endDistance - segment.startDistance
        guard distanceDelta > 0 else {
            return nil
        }
        
        let progress = (distance - segment.startDistance) / distanceDelta
        let activeDuration = segment.startActiveDuration
        + (segment.endActiveDuration - segment.startActiveDuration) * progress
        let timestamp = segment.startDate.addingTimeInterval(
            segment.endDate.timeIntervalSince(segment.startDate) * progress
        )
        
        return DistanceRecordPoint(activeDuration: activeDuration, date: timestamp)
    }
    
    func pauseIntervals(for workout: HKWorkout) -> [DateInterval] {
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
    
    func activeDuration(from start: Date, to end: Date, pauses: [DateInterval]) -> TimeInterval {
        guard end > start else { return 0 }
        
        var duration = end.timeIntervalSince(start)
        let totalRange = DateInterval(start: start, end: end)
        
        for pause in pauses {
            if let intersection = totalRange.intersection(with: pause) {
                duration -= intersection.duration
            }
        }
        
        return max(duration, 0)
    }
    
    func uniqueWorkouts(_ workouts: [Workout]) -> [Workout] {
        var seenIDs: Set<UUID> = []
        var result: [Workout] = []
        
        for workout in workouts where !seenIDs.contains(workout.id) {
            seenIDs.insert(workout.id)
            result.append(workout)
        }
        
        return result
    }
    
    func recordEligibleWorkouts(_ workouts: [Workout]) -> [Workout] {
        let minimumTargetDistance = WorkoutDistanceRecordTarget.allCases
            .map(\.meters)
            .min() ?? 0
        
        return uniqueWorkouts(workouts).filter { $0.distance >= minimumTargetDistance }
    }
}

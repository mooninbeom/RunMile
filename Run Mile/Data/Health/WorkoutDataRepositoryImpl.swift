//
//  WorkoutDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit


final class WorkoutDataRepositoryImpl: WorkoutDataRepository {
    private let store = HKHealthStore()
    
    public func fetchWorkoutData() async throws -> [RunningData] {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let runningData = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], any Error>) in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [.init(key: HKSampleSortIdentifierStartDate, ascending: false)]) { query, samples, error in
                    if let _ = error {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                    }
                    
                    guard let samples = samples else {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                        return
                    }
                    
                    continuation.resume(with: .success(samples))
                }
            
            store.execute(query)
        }
        
        guard let result = runningData as? [HKWorkout] else { throw HealthError.failedToLoadWorkoutData }
        
        return convertToRunningData(result)
    }
}


extension WorkoutDataRepositoryImpl {
    /// HKWorkout 을 RunningData 엔티티로 변환합니다.
    private func convertToRunningData(_ workouts: [HKWorkout]) -> [RunningData] {
        var resultArray = [RunningData]()
        workouts.forEach {
            if let statistics = $0.statistics(for: HKQuantityType(.distanceWalkingRunning)),
               let sumDistance = statistics.sumQuantity()?.doubleValue(for: .meter()) {
                let localStartDate = Calendar.current.date(
                    byAdding: .second,
                    value: TimeZone.current.secondsFromGMT(),
                    to: $0.startDate
                )
                
                let result = RunningData(
                    id: $0.uuid,
                    distance: sumDistance,
                    date: localStartDate
                )
                
                resultArray.append(result)
            }
        }
        
        return resultArray
    }
}

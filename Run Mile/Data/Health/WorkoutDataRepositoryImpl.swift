//
//  WorkoutDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit


actor WorkoutDataRepositoryImpl: WorkoutDataRepository {
    private let store = HKHealthStore()
    
    public func fetchWorkoutData() async throws -> [RunningData] {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        let descriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        
        let result: [HKWorkout] = try await store.fetchData(
            sampleType: .workoutType(),
            predicate: predicate,
            limit: HKObjectQueryNoLimit,
            sortDescriptors: descriptor
        )
        
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

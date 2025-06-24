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
        
        return result.map { $0.toEntity }
    }
}

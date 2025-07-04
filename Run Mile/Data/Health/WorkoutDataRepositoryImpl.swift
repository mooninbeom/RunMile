//
//  WorkoutDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import RealmSwift
import Foundation
import HealthKit


actor WorkoutDataRepositoryImpl: WorkoutDataRepository {
    private let store = HKHealthStore()
    
    public func fetchAllWorkoutData() async throws -> [Workout] {
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
    
    public func fetchUnsavedWorkoutData() async throws -> [Workout] {
        let savedWorkouts = try await fetchSavedWorkoutData()
        let entireWorkouts = try await fetchAllWorkoutData()
        
        let result = entireWorkouts.filter { first in
            !savedWorkouts.contains(where: { $0.id == first.id })
        }
        
        return result
    }
    
    public func fetchSavedWorkoutData() async throws -> [Workout] {
        let realm = try await Realm.open()
        let fetchedResult = realm.objects(WorkoutDTO.self)
        var result = [Workout]()
        
        fetchedResult.forEach {
            result.append(
                .init(id: $0.id, distance: $0.distance, date: $0.date)
            )
        }
        
        return result
    }
}

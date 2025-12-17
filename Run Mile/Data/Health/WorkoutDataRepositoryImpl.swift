//
//  WorkoutDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

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
    
    func fetchSingleWorkoutData(workout: HKWorkout) async throws -> Workout {
        let heartRates = try await fetchDetailedWorkoutData(
            workout: workout,
            type: .init(.heartRate)
        )
        let runningPace = try await fetchDetailedWorkoutData(
            workout: workout,
            type: .init(.runningSpeed)
        )
        let routes = try await fetchDetailedWorkoutRouteData(workout: workout)
        
        let result = Workout(
            workout: workout,
            heartRates: heartRates,
            runningPace: runningPace,
            route: routes!
        )
        
        return result
    }
    
    
    func fetchDetailedWorkoutRouteData(workout: HKWorkout) async throws -> [RoutePoint]? {
        var returnResult: [RoutePoint] = []
        
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
        
        if routes.isEmpty { return nil }
        
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
            
            returnResult.append(contentsOf: routeResult.map {
                RoutePoint(coordinate: $0.coordinate, timestamp: $0.timestamp, altitude: $0.altitude)
            })
        }
        
        return returnResult
    }
    
    func fetchDetailedWorkoutData(workout: HKWorkout, type: HKQuantityType) async throws -> [RunningMetricPoint] {
        let predicate = HKQuery.predicateForObjects(from: workout)
        
        let quantitySamples: [HKQuantitySample] = try await HKHealthStore().fetchData(
            sampleType: type,
            predicate: predicate,
            limit: HKObjectQueryNoLimit
        )
        
        var result: [RunningMetricPoint] = []
        
        quantitySamples.forEach {
            switch type {
            case .init(.heartRate):
                let value = $0.quantity.doubleValue(for: .count().unitDivided(by: .minute()))
                result.append(.init(timestamp: $0.startDate, value: value, unit: "BPM"))
            case .init(.runningSpeed):
                let value = $0.quantity.doubleValue(for: .meter().unitDivided(by: .second()))
                result.append(.init(timestamp: $0.startDate, value: value, unit: "m/s"))
            default: break
            }
        }
        
        return result
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
}

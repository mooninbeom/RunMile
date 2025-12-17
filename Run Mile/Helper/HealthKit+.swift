//
//  HealthKit+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import HealthKit


extension HKHealthStore: Sendable {
    public func fetchData<T: HKSample>(
        sampleType: HKSampleType,
        predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [T] {
        let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], any Error>) in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors) { query, samples, error in
                    if let _ = error {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                        return
                    }
                    
                    guard let samples = samples else {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                        return
                    }
                    
                    continuation.resume(with: .success(samples))
                }
            self.execute(query)
        }
        
        guard let result = data as? [T] else { throw HealthError.failedToLoadWorkoutData }
        
        return result
    }
    
    public func fetchSingleWorkoutData(id: UUID) async throws -> HKWorkout? {
        let sampleType = HKSampleType.workoutType()
        let predicate = HKSampleQuery.predicateForObject(with: id)
        
        let result: [HKWorkout] = try await fetchData(sampleType: sampleType, predicate: predicate, limit: 1)
        
        return result.first
    }
}

extension HKWorkout {
    public func getKilometerDistance() -> Double? {
        if let statistics = self.statistics(for: HKQuantityType(.distanceWalkingRunning)),
           let sumDistance = statistics.sumQuantity() {
            return sumDistance.doubleValue(for: .meterUnit(with: .kilo))
        }
        return nil
    }
    
    public func getMeterDistance() -> Double {
        self.totalDistance?.doubleValue(for: .meter()) ?? 0.0
    }
    
    public func getAvgPace() -> String {
        (self.getMeterDistance() / self.duration).meterPerSecondToPace()
    }
}


// MARK: - Mock Data 메소드
enum HealthKitSampleMethod {
    static func createSampleWorkoutData() {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor
        
        
        let builder = HKWorkoutBuilder(healthStore: .init(), configuration: config, device: .local())
        
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(1800)
        
        let sample = HKQuantitySample(type: .quantityType(forIdentifier: .distanceWalkingRunning)!, quantity: .init(unit: .meter(), doubleValue: 5000), start: startDate, end: endDate)
        
        builder.beginCollection(withStart: startDate) { success, error in
            if let error = error {
                print(error)
                return
            }
            
            if success {
                builder.add([sample]) { success, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    builder.endCollection(withEnd: endDate) { success, error in
                        if let error = error {
                            print(error)
                            return
                        }
                        
                        if success {
                            builder.finishWorkout { workout, error in
                                if let workout = workout {
                                    print(workout)
                                } else {
                                    if let error = error {
                                        print(error)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

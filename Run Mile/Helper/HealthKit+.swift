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
        predicate: NSPredicate? = nil,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [T] {
        let predicate = HKQuery.predicateForWorkouts(with: .running)
        
        let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], any Error>) in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors) { query, samples, error in
                    if let _ = error {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
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
}

extension HKWorkout {
    public func getKilometerDistance() -> Double? {
        if let statistics = self.statistics(for: HKQuantityType(.distanceWalkingRunning)),
           let sumDistance = statistics.sumQuantity() {
            return sumDistance.doubleValue(for: .meterUnit(with: .kilo))
        }
        return nil
    }
    
    public var toEntity: RunningData {
        let statistics = self.statistics(for: HKQuantityType(.distanceWalkingRunning))!
        let sumDistance = statistics.sumQuantity()!
        
        // 실기기 검증 필요
//        let localStartDate = Calendar.current.date(
//            byAdding: .second,
//            value: TimeZone.current.secondsFromGMT(),
//            to: self.startDate
//        )
        
        return .init(
            id: self.uuid,
            distance: sumDistance.doubleValue(for: .meter()),
            date: self.startDate
        )
    }
}


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

//
//  HealthKitSampleSeeder.swift
//  Run Mile
//
//  Created by Codex on 6/18/26.
//

import CoreLocation
import Foundation
import HealthKit


struct HealthKitSampleSeeder: HealthKitSampleSeeding {
    private static let didSeedSampleKey = "HealthKitSampleSeeder.didSeedSample"
    
    private let store = HKHealthStore()
    private let defaults = UserDefaults.standard
    
    /// Debug Simulator에서 HealthKit 권한 요청 이후 테스트 러닝 샘플을 명시적으로 생성합니다.
    func seedSampleIfNeeded() async {
        #if DEBUG && targetEnvironment(simulator)
        guard !defaults.bool(forKey: Self.didSeedSampleKey) else { return }
        
        do {
            let workout = try await createDetailedRunningWorkout()
            defaults.set(true, forKey: Self.didSeedSampleKey)
            print("[HealthKitSampleSeeder] seeded sample workout: \(workout.uuid)")
        } catch {
            print("[HealthKitSampleSeeder] failed to seed sample: \(error.localizedDescription)")
        }
        #endif
    }
}


#if DEBUG && targetEnvironment(simulator)
private extension HealthKitSampleSeeder {
    func createDetailedRunningWorkout() async throws -> HKWorkout {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor
        
        let builder = HKWorkoutBuilder(
            healthStore: store,
            configuration: config,
            device: .local()
        )
        
        let startDate = Date().addingTimeInterval(-3600)
        let duration: TimeInterval = 1800
        let endDate = startDate.addingTimeInterval(duration)
        
        try await builder.beginCollection(at: startDate)
        
        let samples = makeWorkoutSamples(startDate: startDate, endDate: endDate, duration: duration)
        let didAddSamples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            builder.add(samples) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: success)
            }
        }
        
        guard didAddSamples else { throw HealthError.failedToLoadWorkoutData }
        
        try await builder.endCollection(at: endDate)
        
        let workout = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKWorkout?, Error>) in
            builder.finishWorkout { workout, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: workout)
            }
        }
        
        guard let savedWorkout = workout else {
            throw HealthError.failedToLoadWorkoutData
        }
        
        try await addRouteData(to: savedWorkout, start: startDate, duration: duration)
        return savedWorkout
    }
    
    func makeWorkoutSamples(
        startDate: Date,
        endDate: Date,
        duration: TimeInterval
    ) -> [HKSample] {
        var samples: [HKSample] = []
        
        for index in 0..<Int(duration / 5) {
            let time = startDate.addingTimeInterval(Double(index) * 5)
            
            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            samples.append(
                HKQuantitySample(
                    type: heartRateType,
                    quantity: HKQuantity(
                        unit: .count().unitDivided(by: .minute()),
                        doubleValue: Double.random(in: 140...160)
                    ),
                    start: time,
                    end: time
                )
            )
            
            let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
            samples.append(
                HKQuantitySample(
                    type: speedType,
                    quantity: HKQuantity(
                        unit: .meter().unitDivided(by: .second()),
                        doubleValue: Double.random(in: 2.5...3.5)
                    ),
                    start: time,
                    end: time
                )
            )
            
            let powerType = HKQuantityType.quantityType(forIdentifier: .runningPower)!
            samples.append(
                HKQuantitySample(
                    type: powerType,
                    quantity: HKQuantity(unit: .watt(), doubleValue: Double.random(in: 200...250)),
                    start: time,
                    end: time
                )
            )
            
            let verticalOscillationType = HKQuantityType.quantityType(forIdentifier: .runningVerticalOscillation)!
            samples.append(
                HKQuantitySample(
                    type: verticalOscillationType,
                    quantity: HKQuantity(
                        unit: .meterUnit(with: .centi),
                        doubleValue: Double.random(in: 6...10)
                    ),
                    start: time,
                    end: time
                )
            )
            
            let groundContactTimeType = HKQuantityType.quantityType(forIdentifier: .runningGroundContactTime)!
            samples.append(
                HKQuantitySample(
                    type: groundContactTimeType,
                    quantity: HKQuantity(
                        unit: .secondUnit(with: .milli),
                        doubleValue: Double.random(in: 220...260)
                    ),
                    start: time,
                    end: time
                )
            )
        }
        
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        samples.append(
            HKQuantitySample(
                type: distanceType,
                quantity: HKQuantity(unit: .meter(), doubleValue: 5000),
                start: startDate,
                end: endDate
            )
        )
        
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        samples.append(
            HKQuantitySample(
                type: energyType,
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: 350),
                start: startDate,
                end: endDate
            )
        )
        
        return samples
    }
    
    func addRouteData(
        to workout: HKWorkout,
        start: Date,
        duration: TimeInterval
    ) async throws {
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: store, device: .local())
        let locations = makeRouteLocations(start: start, duration: duration)
        
        let didInsertRoute = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            routeBuilder.insertRouteData(locations) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: success)
            }
        }
        
        guard didInsertRoute else { throw HealthError.failedToLoadWorkoutData }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            routeBuilder.finishRoute(with: workout, metadata: nil) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                continuation.resume(returning: ())
            }
        }
    }
    
    func makeRouteLocations(start: Date, duration: TimeInterval) -> [CLLocation] {
        let startLat = 37.528
        let startLon = 126.932
        
        return (0..<Int(duration / 5)).map { index in
            CLLocation(
                coordinate: CLLocationCoordinate2D(
                    latitude: startLat + Double.random(in: -0.0001...0.0001),
                    longitude: startLon + Double(index) * 0.0001
                ),
                altitude: 10,
                horizontalAccuracy: 5,
                verticalAccuracy: 5,
                timestamp: start.addingTimeInterval(Double(index) * 5)
            )
        }
    }
}
#endif

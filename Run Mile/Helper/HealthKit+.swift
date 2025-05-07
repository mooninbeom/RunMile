//
//  HealthKit+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import HealthKit


struct HealthKitSampleMethod {
    private init() {}
    
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

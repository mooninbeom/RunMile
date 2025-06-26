//
//  BackgroundTaskManager.swift
//  Run Mile
//
//  Created by 문인범 on 5/10/25.
//

import HealthKit
import BackgroundTasks


final class BackgroundTaskManager {
    public static let shared = BackgroundTaskManager()
    
    private let taskId = ["com.mooni.test"]
    
    private init() {}
}

extension BackgroundTaskManager {
    public func registerBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId[0], using: nil) { task in
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.createMockWorkoutSampleWithBGTask(task: task as! BGAppRefreshTask)
            }
        }
    }
    
    public func submitBackgroundTask() throws {
        let task = BGAppRefreshTaskRequest(identifier: taskId[0])
        
        task.earliestBeginDate = .now + 10
        
        try BGTaskScheduler.shared.submit(task)
        print("Background Task Submit!")
    }
}

extension BackgroundTaskManager {
    /// 백그라운드 테스트 용 Workout Sample 생성
    private func createMockWorkoutSampleWithBGTask(task: BGAppRefreshTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
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
                task.setTaskCompleted(success: false)
                return
            }
            
            if success {
                builder.add([sample]) { success, error in
                    if let error = error {
                        print(error)
                        task.setTaskCompleted(success: false)
                        return
                    }
                    
                    builder.endCollection(withEnd: endDate) { success, error in
                        if let error = error {
                            print(error)
                            task.setTaskCompleted(success: false)
                            return
                        }
                        
                        if success {
                            builder.finishWorkout { workout, error in
                                if let workout = workout {
                                    print(workout)
                                    task.setTaskCompleted(success: true)
                                } else {
                                    if let error = error {
                                        print(error)
                                        task.setTaskCompleted(success: false)
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

//
//  Mapper.swift
//  Run Mile
//
//  Created by 문인범 on 12/17/25.
//

import HealthKit


enum DTOMapper {
    private static let healthStore = HKHealthStore()
    
    public static func CDShoesDTOToEntities(_ dto: [CDShoesDTO]) async throws -> [Shoes] {
        var resultArray: [Shoes] = []
        
        for shoe in dto {
            var workouts = [Workout]()
            
            for workout in shoe.workoutDTOArray {
                guard let workoutObject = try await healthStore.fetchSingleWorkoutData(id: workout.id!) else {
                    throw NSError()
                }
                
                workouts.append(.init(
                    workout: workoutObject
                ))
            }
            
            let result = Shoes(
                id: shoe.id ?? .init(),
                image: shoe.image ?? .init(),
                shoesName: shoe.shoesName ?? "Undefined",
                nickname: shoe.nickname ?? "Undefined",
                goalMileage: shoe.goalMileage,
                currentMileage: shoe.currentMileage,
                workouts: workouts,
                isGraduate: shoe.isGraduated
            )
            
            resultArray.append(result)
        }
        
        return resultArray
    }
    
    public static func CDWorkoutDTOtoEntities(_ dto: [CDWorkoutDTO]) async throws -> [Workout] {
        var resultArray: [Workout] = []
        
        for workout in dto {
            let workoutId = workout.id!
            
            if let fetchedResult = try await healthStore.fetchSingleWorkoutData(id: workoutId) {
                resultArray.append(.init(
                    workout: fetchedResult
                ))
            }
        }
        
        return resultArray
    }
    
    public static func normalizeData(workout: HKWorkout, data: [RunningMetricPoint]) -> [UnifiedWorkoutDetailData] {
        var result = [UnifiedWorkoutDetailData]()
        var index = 0
        
        var currentValue: Double? = nil
        
        let startDate = workout.startDate
        let endDate = workout.endDate
        let durationSeconds = Int(endDate.timeIntervalSince(startDate))
        
        let gapThreshold: TimeInterval = 30.0
        var lastValidTime: Date? = nil
        
        for t in 0...(durationSeconds) {
            let currentTime = startDate.addingTimeInterval(TimeInterval(t))
            
            while index < data.count && data[index].timestamp <= currentTime {
                currentValue = Double(data[index].value)
                lastValidTime = data[index].timestamp
                index += 1
            }
            
            if let lastTime = lastValidTime,
               currentTime.timeIntervalSince(lastTime) <= gapThreshold {
            } else {
                currentValue = nil
            }
            
            let point = UnifiedWorkoutDetailData(
                seconds: t,
                date: currentTime,
                value: currentValue
            )
            
            result.append(point)
        }   
        return result
    }
}

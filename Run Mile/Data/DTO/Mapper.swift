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
}

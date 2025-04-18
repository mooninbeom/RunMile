//
//  ShoesDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import RealmSwift


actor ShoesDataRepositoryImpl: ShoesDataRepository {
    private let realm: Realm!
    
    init() async throws {
        self.realm = try await Realm.open()
    }
    
    public func fetchAllShoes() async throws -> [Shoes] {
        let fetchedResult = realm.objects(ShoesDTO.self)
        
        let result = toEntities(fetchedResult)
        
        return result
    }
    
    public func fetchCurrentShoes() async throws -> [Shoes] {
        let fetchedResult = realm.objects(ShoesDTO.self).where { !$0.isGraduated }
        let result = toEntities(fetchedResult)
        return result
    }
    
    
    public func fetchHOFShoes() async throws -> [Shoes] {
        let fetchedResult = realm.objects(ShoesDTO.self).where { $0.isGraduated }
        let result = toEntities(fetchedResult)
        return result
    }
    
    public func fetchSingleShoes(id: UUID) async throws -> Shoes {
        let fetchedResult = realm.object(ofType: ShoesDTO.self, forPrimaryKey: id)
        
        if let result = fetchedResult {
            var workouts = [RunningData]()
            result.workouts.forEach { workout in
                workouts.append(
                    RunningData(
                        id: workout.id,
                        distance: workout.distance,
                        date: workout.date
                    )
                )
            }
            
            return Shoes(
                id: result.id,
                image: result.image,
                shoesName: result.shoesName,
                nickname: result.nickname,
                goalMileage: result.goalMileage,
                currentMileage: result.currentMileage,
                workouts: workouts
                
            )
        } else {
            throw NSError()
        }
    }
}

extension ShoesDataRepositoryImpl {
    private func toEntities(_ dto: Results<ShoesDTO>) -> [Shoes] {
        var resultArray: [Shoes] = []
        dto.forEach {
            var workouts = [RunningData]()
            $0.workouts.forEach { workout in
                workouts.append(
                    RunningData(
                        id: workout.id,
                        distance: workout.distance,
                        date: workout.date
                    )
                )
            }
            
            let shoe = Shoes(
                id: $0.id,
                image: $0.image,
                shoesName: $0.shoesName,
                nickname: $0.nickname,
                goalMileage: $0.goalMileage,
                currentMileage: $0.currentMileage,
                workouts: workouts
            )
            resultArray.append(shoe)
        }
        
        return resultArray
    }
}

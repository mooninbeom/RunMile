//
//  ShoesDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import RealmSwift


actor ShoesDataRepositoryImpl: ShoesDataRepository {
    public func fetchAllShoes() async throws -> [Shoes] {
        let realm = try await Realm.open()
        let fetchedResult = realm.objects(ShoesDTO.self)
        let result = toEntities(fetchedResult)
        return result
    }
    
    public func fetchCurrentShoes() async throws -> [Shoes] {
        let realm = try await Realm.open()
        let fetchedResult = realm.objects(ShoesDTO.self).where { !$0.isGraduated }
        let result = toEntities(fetchedResult)
        return result
    }
    
    
    public func fetchHOFShoes() async throws -> [Shoes] {
        let realm = try await Realm.open()
        let fetchedResult = realm.objects(ShoesDTO.self).where { $0.isGraduated }
        let result = toEntities(fetchedResult)
        return result
    }
    
    public func fetchSingleShoes(id: UUID) async throws -> Shoes {
        let realm = try await Realm.open()
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
            // TODO: 에러 처리
            throw NSError()
        }
    }
    
    public func createShoes(shoes: Shoes) async throws {
        let realm = try await Realm.open()
        let dto = ShoesDTO()
        dto.image = shoes.image
        dto.shoesName = shoes.shoesName
        dto.nickname = shoes.nickname
        dto.goalMileage = shoes.goalMileage
        dto.currentMileage = shoes.currentMileage
        
        try realm.write {
            realm.add(dto)
        }
    }
    
    public func updateShoes(shoes: Shoes) async throws {
        let realm = try await Realm.open()
        
        var list = List<WorkoutDTO>()
        
        shoes.workouts.forEach {
            let workoutDTO = WorkoutDTO()
            workoutDTO.id = $0.id
            workoutDTO.distance = $0.distance
            workoutDTO.date = $0.date
            list.append(workoutDTO)
        }
        
        list.sort(by: { $0.date ?? .now > $1.date ?? .now })
        
        let dto = ShoesDTO()
        dto.id = shoes.id
        dto.image = shoes.image
        dto.shoesName = shoes.shoesName
        dto.nickname = shoes.nickname
        dto.goalMileage = shoes.goalMileage
        dto.currentMileage = shoes.currentMileage
        dto.isGraduated = shoes.isGradutate
        dto.workouts = list
        
        try realm.write {
            realm.add(dto, update: .modified)
        }
    }
    
    public func deleteShoes(shoes: Shoes) async throws {
        let realm = try await Realm.open()
        if let shoesDTO = realm.object(ofType: ShoesDTO.self, forPrimaryKey: shoes.id) {
            try realm.write {
                realm.delete(shoesDTO)
            }
        }
    }
    
    public func updateSelectedShoes(shoes: Shoes) async {
        if UserDefaults.standard.selectedShoesID == shoes.id.uuidString {
            UserDefaults.standard.selectedShoesID = ""
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

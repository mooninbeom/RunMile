//
//  ShoesDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import CoreData


actor ShoesDataRepositoryImpl: ShoesDataRepository {
    public func fetchAllShoes() async throws -> [Shoes] {
        let request: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
        let results = try CoreDataManager.shared.context.fetch(request)
        return try await DTOMapper.CDShoesDTOToEntities(results)
    }
    
    public func fetchCurrentShoes() async throws -> [Shoes] {
        let request: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
        let results = try CoreDataManager.shared.context.fetch(request)
        
        return try await DTOMapper.CDShoesDTOToEntities(results.filter({ !$0.isGraduated }))
    }


    public func fetchHOFShoes() async throws -> [Shoes] {
        let request: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
        request.predicate = NSPredicate(format: "isGraduated == YES")
        let results = try CoreDataManager.shared.context.fetch(request)

        return try await DTOMapper.CDShoesDTOToEntities(results)
    }

    public func fetchSingleShoes(id: UUID) async throws -> Shoes {
        let request: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        let result = try CoreDataManager.shared.context.fetch(request)

        if let entity = try await DTOMapper.CDShoesDTOToEntities(result).first {
            return entity
        } else {
            throw RepositoryError.fetchFailed
        }
    }

    public func createShoes(shoes: Shoes) async throws {
        let context = CoreDataManager.shared.backgroundContext

        try await context.perform {
            let CDShoes = CDShoesDTO(context: context)
            CDShoes.id = UUID()
            CDShoes.createdAt = .now
            CDShoes.image = shoes.image
            CDShoes.shoesName = shoes.shoesName
            CDShoes.nickname = shoes.nickname
            CDShoes.goalMileage = shoes.goalMileage
            CDShoes.currentMileage = shoes.currentMileage
            CDShoes.isGraduated = false
            CDShoes.graduatedAt = nil

            try context.save()
        }
    }

    public func updateShoes(shoes: Shoes) async throws {
        let context = CoreDataManager.shared.backgroundContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        try await context.perform {
            let request: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", shoes.id as CVarArg)
            let result = try context.fetch(request)


            if let entity = result.first {
                entity.image = shoes.image
                entity.shoesName = shoes.shoesName
                entity.nickname = shoes.nickname
                entity.goalMileage = shoes.goalMileage
                entity.currentMileage = shoes.currentMileage

                entity.isGraduated = shoes.isGradutate
                if shoes.isGradutate {
                    entity.graduatedAt = shoes.graduatedAt ?? entity.graduatedAt ?? Date()
                } else {
                    entity.graduatedAt = nil
                }

                let existingWorkouts = (entity.workouts as? Set<CDWorkoutDTO>) ?? []
                var workoutMap = Dictionary<UUID, CDWorkoutDTO>(
                    uniqueKeysWithValues: existingWorkouts.compactMap { entity in
                        guard let id = entity.id else { return nil }
                        return (id, entity) // Key: UUID, Value: Entity
                    }
                )

                for workoutModel in shoes.workouts {
                    let workoutEntity: CDWorkoutDTO

                    if let existing = workoutMap[workoutModel.id] {
                        // A. 이미 존재하면 -> 가져오고, Map에서 제거 (처리됨 표시)
                        workoutEntity = existing
                        workoutMap.removeValue(forKey: workoutModel.id)
                    } else {
                        // B. 없으면 -> 새로 생성 및 부모 연결
                        workoutEntity = CDWorkoutDTO(context: context)
                        workoutEntity.id = workoutModel.id
                        // 관계 연결 (중요)
                        workoutEntity.shoes = entity
                    }

                    // 속성 업데이트 (공통)
                    workoutEntity.distance = workoutModel.distance
                    workoutEntity.date = workoutModel.date
                }

                for orphanedEntity in workoutMap.values {
                    context.delete(orphanedEntity)
                }
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func registerWorkouts(
        shoes: Shoes,
        workouts: [Workout],
        shouldMoveRegisteredWorkouts: Bool
    ) async throws {
        let context = CoreDataManager.shared.backgroundContext
        context.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump

        try await context.perform {
            let targetShoesRequest: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
            targetShoesRequest.predicate = NSPredicate(format: "id == %@", shoes.id as CVarArg)

            guard let targetShoes = try context.fetch(targetShoesRequest).first else {
                throw RepositoryError.fetchFailed
            }

            for workout in workouts {
                let workoutRequest: NSFetchRequest<CDWorkoutDTO> = CDWorkoutDTO.fetchRequest()
                workoutRequest.predicate = NSPredicate(format: "id == %@", workout.id as CVarArg)
                let existingWorkouts = try context.fetch(workoutRequest)

                let workoutEntity = existingWorkouts.first { $0.shoes?.id == targetShoes.id } ?? existingWorkouts.first

                if let workoutEntity {
                    let canAttachToTarget = shouldMoveRegisteredWorkouts ||
                        workoutEntity.shoes?.id == targetShoes.id ||
                        workoutEntity.shoes == nil

                    guard canAttachToTarget else {
                        continue
                    }

                    workoutEntity.shoes = targetShoes
                    workoutEntity.distance = workout.distance
                    workoutEntity.date = workout.date

                    for duplicate in existingWorkouts where duplicate.objectID != workoutEntity.objectID {
                        context.delete(duplicate)
                    }
                } else {
                    let workoutEntity = CDWorkoutDTO(context: context)
                    workoutEntity.id = workout.id
                    workoutEntity.distance = workout.distance
                    workoutEntity.date = workout.date
                    workoutEntity.shoes = targetShoes
                }
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func deleteShoes(shoes: Shoes) async throws {
        let context = CoreDataManager.shared.backgroundContext

        try await context.perform {
            let request: NSFetchRequest<CDShoesDTO> = CDShoesDTO.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", shoes.id as CVarArg)

            let fetchedResult = try context.fetch(request)

            if let entityToDelete = fetchedResult.first {
                context.delete(entityToDelete)
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    public func updateSelectedShoes(shoes: Shoes) async {
        if UserDefaults.standard.selectedShoesID == shoes.id.uuidString {
            UserDefaults.standard.selectedShoesID = ""
        }
    }
}

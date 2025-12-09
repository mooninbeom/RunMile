//
//  MigrationService.swift
//  Run Mile
//
//  Created by 문인범 on 12/9/25.
//

import CoreData
import RealmSwift


final class MigrationService {
    static let shared: MigrationService = .init()
    private init() {}
    
    public func migrateRealmToCoreData() async throws -> Bool {
        let isMigrated = UserDefaults.standard.isMigratedToCoreData
        
        if isMigrated {
            return false
        }
        
        let context = CoreDataManager.shared.backgroundContext
        
        try await context.perform {
            let realm = try Realm()
            let realmObjects = realm.objects(ShoesDTO.self)
            
            for object in realmObjects {
                let cdObject = CDShoesDTO(context: context)
                cdObject.id = object.id
                cdObject.createdAt = object.createdAt
                cdObject.currentMileage = object.currentMileage
                cdObject.goalMileage = object.goalMileage
                cdObject.image = object.image
                cdObject.isGraduated = object.isGraduated
                cdObject.nickname = object.nickname
                cdObject.shoesName = object.shoesName
                
                object.workouts.forEach {
                    let cdWorkout = CDWorkoutDTO(context: context)
                    cdWorkout.id = $0.id
                    cdWorkout.date = $0.date
                    cdWorkout.distance = $0.distance
                    
                    cdWorkout.shoes = cdObject
                }
            }
            
            if context.hasChanges {
                try context.save()
            }
        }
        
        UserDefaults.standard.isMigratedToCoreData = true
        
        return true
    }
}

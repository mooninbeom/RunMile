//
//  CoreDataManager.swift
//  Run Mile
//
//  Created by 문인범 on 12/9/25.
//

import CoreData


final class CoreDataManager {
    static let shared: CoreDataManager = .init()

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "RunMileModel") // .xcdatamodeld 파일 이름
        container.persistentStoreDescriptions.forEach {
            $0.shouldMigrateStoreAutomatically = true
            $0.shouldInferMappingModelAutomatically = true
        }
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data Store 로드 실패: \(error)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        return container
    }()

    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // 백그라운드 작업을 위한 컨텍스트
    public var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }

    public func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}


extension CDShoesDTO {
    public var workoutDTOArray: [CDWorkoutDTO] {
        let swiftSet = self.workouts as? Set<CDWorkoutDTO> ?? []
        return swiftSet.sorted {
            $0.date ?? .now > $1.date ?? .now
        }
    }
}

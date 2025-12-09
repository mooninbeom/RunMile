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
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data Store 로드 실패: \(error)")
            }
        }
        return container
    }()
    
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // 백그라운드 작업을 위한 컨텍스트
    private var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
    }
    
    private func saveContext() {
        if context.hasChanges {
            try? context.save()
        }
    }
}

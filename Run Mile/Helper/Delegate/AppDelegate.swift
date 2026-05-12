//
//  AppDelegate.swift
//  Run Mile
//
//  Created by 문인범 on 5/5/25.
//

import UIKit
import UserNotifications
import Firebase
import RealmSwift


final class AppDelegate: NSObject, UIApplicationDelegate {
    private let healthBackgroundSyncService = AppDIContainer.shared.makeHealthBackgroundSyncService()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        self.realmMigration()
        FirebaseApp.configure()
        self.registerWorkoutShoesBackgroundSync()
        
        Task {
            await self.userNotificationAuthorize()
            await self.prepareWorkoutShoesBackgroundSync()
            await self.migrateRealmToCD()
        }
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: "Default", sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }
}


// MARK: - Workout/Shoes Data

extension AppDelegate {
    /// DIContainer가 보관하는 HealthKit 백그라운드 동기화 서비스에 observer query 등록을 위임합니다.
    ///
    /// AppDelegate는 앱 생명주기 진입점만 담당하고, 실제 운동 변경 감지와 신발 자동 등록 플로우는
    /// `DefaultHealthBackgroundSyncService`가 처리합니다.
    private func registerWorkoutShoesBackgroundSync() {
        healthBackgroundSyncService.registerHealthBackgroundQueryTask()
    }
    
    /// HealthKit background delivery와 이전 실행에서 완료하지 못한 운동 처리 재시도를 준비합니다.
    private func prepareWorkoutShoesBackgroundSync() async {
        await healthBackgroundSyncService.enableBackgroundDelivery()
        await healthBackgroundSyncService.processPendingRunningWorkoutsIfNeeded()
    }
}


// MARK: - UserNotifications

extension AppDelegate {
    /// UserNotification 권한 허용
    private func userNotificationAuthorize() async {
        let notiCenter = UNUserNotificationCenter.current()
        
        notiCenter.delegate = self
        
        let settings = await notiCenter.notificationSettings()
        
        if case .notDetermined = settings.authorizationStatus {
            do {
                try await notiCenter.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                print(error)
            }
        }
    }
}

// MARK: - Others

extension AppDelegate {
    
    // TODO: Error Handling
    private func migrateRealmToCD() async {
        do {
            let didMigrate = try await MigrationService.shared.migrateRealmToCoreData()
            
            if didMigrate {
                print("데이터 이전 작업을 마쳤습니다.")
            } else {
                print("Failed!!")
            }
        } catch {
            print("❌ 마이그레이션 실패: \(error)")
        }
    }
    
    /// Realm 스키마 마이그레이션
    private func realmMigration() {
        let config = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldSchemaVersion in
                /// Version 1
                /// WorkoutDTO : 역관계 추가 <-> ShoesDTO
                if oldSchemaVersion < 1 {
                    
                }
            }
        )
        
        Realm.Configuration.defaultConfiguration = config
        
        #if DEBUG
        // Debug용 print
        print(Realm.Configuration.defaultConfiguration.fileURL ?? "알 수 없음")
        #endif
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Push Notification 액션 Delegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        if let category = userInfo["category"] as? String,
           category == "ManualRegister",
           let uuidString = userInfo["id"] as? String,
           let uuid = UUID(uuidString: uuidString),
           let dateString = userInfo["date"] as? String,
           let date = dateFormatter.date(from: dateString),
           let distanceString = userInfo["distance"] as? String,
           let distance = Double(distanceString)
        {
            // TODO: To be completed
//            let runningData = Workout(
//                id: uuid,
//                distance: distance,
//                date: date
//            )
//            
//            NavigationCoordinator.shared.push(.chooseShoes([runningData], {}))
        }
        
        completionHandler()
    }
    
    /// Push Notfication 생성 Delegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.list, .banner, .badge, .banner])
    }
}

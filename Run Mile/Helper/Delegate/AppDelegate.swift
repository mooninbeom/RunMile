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
        self.configureUserNotifications()
        
        Task {
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
    /// 앱 시작 시에는 권한을 요청하지 않고, 수신/탭 처리를 위한 delegate만 설정합니다.
    private func configureUserNotifications() {
        UNUserNotificationCenter.current().delegate = self
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
        
        guard routeManualRegisterNotification(userInfo: userInfo, completionHandler: completionHandler) else {
            completionHandler()
            return
        }
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

private extension AppDelegate {
    /// 수동 등록 노티를 탭했을 때 workout UUID를 복원해 신발 선택 화면으로 이동합니다.
    func routeManualRegisterNotification(
        userInfo: [AnyHashable: Any],
        completionHandler: @escaping () -> Void
    ) -> Bool {
        guard let category = userInfo["category"] as? String,
              category == UserNotificationsManager.NotificationCategory.manualRegisterRawValue,
              let uuidString = userInfo["id"] as? String,
              let workoutID = UUID(uuidString: uuidString) else {
            return false
        }
        
        Task {
            await navigateToManualWorkoutRegistration(workoutID: workoutID)
            completionHandler()
        }
        
        return true
    }
    
    /// HealthKit에서 workout을 다시 가져온 뒤 선택된 운동을 신발에 등록하는 Sheet를 표시합니다.
    func navigateToManualWorkoutRegistration(workoutID: UUID) async {
        do {
            guard let workout = try await healthBackgroundSyncService.fetchRunningWorkout(id: workoutID) else {
                presentWorkoutRegistrationFailureAlert()
                return
            }
            
            await NavigationCoordinator.shared.push(.chooseShoes([workout], {}))
        } catch {
            print(error.localizedDescription)
            presentWorkoutRegistrationFailureAlert()
        }
    }
    
    /// 노티에 연결된 workout을 찾지 못했을 때 사용자에게 안내합니다.
    @MainActor
    func presentWorkoutRegistrationFailureAlert() {
        NavigationCoordinator.shared.push(.init(
            title: "운동 기록을 불러오지 못했습니다.",
            message: "해당 운동이 삭제되었거나 HealthKit에서 아직 조회되지 않았습니다.",
            firstButton: .cancel(title: "확인", action: {}),
            secondButton: nil
        ))
    }
}

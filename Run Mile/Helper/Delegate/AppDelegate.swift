//
//  AppDelegate.swift
//  Run Mile
//
//  Created by 문인범 on 5/5/25.
//

import UIKit
import SwiftUI
import HealthKit
import RealmSwift


final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        self.realmMigration()
        
        Task {
            await self.userNotificationAuthorize()
            await Self.setBackgroundDelivery()
            self.setHealthBackgroundQueryTask()
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
    
    /// 백그라운드에서 Health 데이터 사용 업데이트 설정
    public static func setBackgroundDelivery() async {
        let store = HKHealthStore()
        
        do {
            try await store.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// 백그라운드에서 사용할 HealthKit Query 설정
    private func setHealthBackgroundQueryTask() {
        let store = HKHealthStore()
        
        let anchoredQuery = HKAnchoredObjectQuery(
            type: .workoutType(),
            predicate: nil,
            anchor: UserDefaults.standard.lastAnchor,
            limit: HKObjectQueryNoLimit
        ) { query, samples, deletedObjects, anchor, error in
            if UserDefaults.standard.lastAnchor != anchor {
                UserDefaults.standard.lastAnchor = anchor
            }
        }
        
        anchoredQuery.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            let currentAnchor = UserDefaults.standard.lastAnchor
            
            if currentAnchor != anchor {
                UserDefaults.standard.lastAnchor = anchor
            } else {
                return
            }
            
            if let error = error {
                print(error)
                return
            }
            
            guard let samples = samples as? [HKWorkout],
                  !samples.isEmpty
            else {
                print(#function)
                return
            }
            
            guard let workout = samples.first else {
                return
            }
            
            guard case .running = workout.workoutActivityType else {
                return
            }
            
            let distance = workout.getKilometerDistance()
            
            if !UserDefaults.standard.selectedShoesID.isEmpty {
                UserNotificationsManager.requestNotification(
                    category: .autoRegister(workout.toEntity),
                    title: String(format: "%.2fkm 러닝 완료 🔥🔥", distance!),
                    body: distance == nil
                    ? "신발에 자동 등록이 완료되었습니다!"
                    : String(format: "신발에 자동 등록이 완료되었습니다. 러닝 후 스트레칭 꼭 잊지 마세요!", distance!)
                )
                
                self?.autoRegisterShoes(workout: workout)
            } else {
                UserNotificationsManager.requestNotification(
                    category: .manualRegister(workout.toEntity),
                    title: String(format: "%.2fkm 러닝 완료 🔥🔥", distance!),
                    body: distance == nil
                    ? "신발 마일리지를 등록할 준비가 완료되었습니다. 등록하러 가볼까요?"
                    : String(format: "%.2fkm, 잊지 말고 마일리지를 등록하러 오세요!", distance!)
                )
            }
        }
        
        store.execute(anchoredQuery)
    }
    
    /// 업데이트된 운동 자동 등록 메소드
    private func autoRegisterShoes(workout: HKWorkout) {
        let shoesDataRepository: ShoesDataRepository = ShoesDataRepositoryImpl()
        
        Task {
            do {
                let shoesID = UUID(uuidString: UserDefaults.standard.selectedShoesID)!
                let shoes = try await shoesDataRepository.fetchSingleShoes(id: shoesID)
                var workouts = shoes.workouts
                workouts.append(workout.toEntity)
                
                let newShoes = Shoes(
                    id: shoes.id,
                    image: shoes.image,
                    shoesName: shoes.shoesName,
                    nickname: shoes.nickname,
                    goalMileage: shoes.goalMileage,
                    currentMileage: shoes.currentMileage,
                    workouts: workouts
                )
                
                try await shoesDataRepository.updateShoes(shoes: newShoes)
            } catch {
                UserNotificationsManager.requestNotification(
                    category: .manualRegister(workout.toEntity),
                    title: "마일리지 자동 등록에 실패했습니다.",
                    body: "앱에서 수동으로 등록 부탁드립니다."
                )
            }
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
            let runningData = Workout(
                id: uuid,
                distance: distance,
                date: date
            )
            
            NavigationCoordinator.shared.push(.chooseShoes([runningData], {}))
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

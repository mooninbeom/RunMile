//
//  AppDelegate.swift
//  Run Mile
//
//  Created by 문인범 on 5/5/25.
//

import UIKit
import HealthKit
import SwiftUI


final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        Task {
            await self.userNotificationAuthorize()
            await AppDelegate.setHealthBackgroundTask()
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
    
    public static func setHealthBackgroundTask() async {
        let store = HKHealthStore()
        
        do {
            try await store.enableBackgroundDelivery(for: .workoutType(), frequency: .immediate)
            let query = HKObserverQuery(
                sampleType: .workoutType(),
                predicate: nil
            ) { query, completionHandler, error in
                if let error = error {
                    print(error)
                    return
                }
                
                let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
                let sampleQuery = HKSampleQuery(queryDescriptors: [.init(sampleType: .workoutType(), predicate: nil)], limit: 1, sortDescriptors: [sort]) { _, samples, error in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    defer {
                        UserDefaults.standard.isFirstLaunch = true
                    }
                    
                    guard let workout = samples?.first as? HKWorkout else {
                        return
                    }
                    
                    guard case .running = workout.workoutActivityType else {
                        return
                    }
                    
                    let workoutId = workout.uuid.uuidString
                    let currentId = UserDefaults.standard.recentWorkoutID
                    
                    if !UserDefaults.standard.isFirstLaunch {
                        UserDefaults.standard.recentWorkoutID = workoutId
                    } else {
                        if workoutId != currentId {
                            let distance = workout.getKilometerDistance()
                            if !UserDefaults.standard.selectedShoesID.isEmpty {

                                UNUserNotificationCenter.requestNotification(
                                    title: "운동을 완료하셨군요!🔥🔥",
                                    body: distance == nil
                                    ? "신발에 자동 등록이 완료되었습니다!"
                                    : String(format: "%.2fkm 달리기! 신발에 자동 등록이 완료되었습니다!", distance!)
                                )
                                
                                autoRegisterShoes(workout: workout)
                            } else {
                                UNUserNotificationCenter.requestNotification(
                                    title: "운동을 완료하셨군요!🔥🔥",
                                    body: distance == nil
                                    ? "신발 마일리지를 등록할 준비가 완료되었습니다. 등록하러 가볼까요?"
                                    : String(format: "%.2fkm 달리기! 신발 마일리지를 등록해보세요!", distance!)
                                )
                            }
                            UserDefaults.standard.recentWorkoutID = workoutId
                        }
                    }
                }
                
                store.execute(sampleQuery)
                
                completionHandler()
            }
            
            store.execute(query)
        } catch {
            print(error)
        }
    }
    
    private static func autoRegisterShoes(workout: HKWorkout) {
        let shoesDataRepository: ShoesDataRepository = ShoesDataRepositoryImpl()
        
        Task {
            do {
                let shoesID = UUID(uuidString: UserDefaults.standard.selectedShoesID)!
                let shoes = try await shoesDataRepository.fetchSingleShoes(id: shoesID)
                var workouts = shoes.workouts
                workouts.append(workout.toEntity())
                
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
                // TODO: Error handling
                print(error)
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Push Notification 액션 Delegate
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
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

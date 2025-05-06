//
//  AppDelegate.swift
//  Run Mile
//
//  Created by 문인범 on 5/5/25.
//

import UIKit
import HealthKit



final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        
        Task {
            await self.userNotificationAuthorize()
            await self.setHealthBackgroundTask()
        }
        
        return true
    }
    
    func applicationDidEnterBackground(
        _ application: UIApplication
    ) {
        
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
    
    private func setHealthBackgroundTask() async {
        let store = HKHealthStore()
        
        UserDefaults.standard.isFirstLaunch = true
        
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
                
                if UserDefaults.standard.isFirstLaunch {
                    UserDefaults.standard.isFirstLaunch = false
                } else {
                    UNUserNotificationCenter.requestNotification(
                        title: "운동을 완료하셨군요!🔥🔥",
                        body: "신발 마일리지를 등록할 준비가 완료되었습니다. 등록하러 가볼까요?"
                    )
                }
                completionHandler()
            }
            
            store.execute(query)
        } catch {
            print(error)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    /// Push Notification 액션 Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    /// Push Notfication 생성 Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .badge, .banner])
    }
}

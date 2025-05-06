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
}


extension AppDelegate {
    public func userNotificationAuthorize() async {
        let notiCenter = UNUserNotificationCenter.current()
        
        let settings = await notiCenter.notificationSettings()
        
        if case .notDetermined = settings.authorizationStatus {
            do {
                try await notiCenter.requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                print(error)
            }
        }
    }
    
    public func setHealthBackgroundTask() async {
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
                
                completionHandler()
            }
            
            store.execute(query)
        } catch {
            print(error)
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
}

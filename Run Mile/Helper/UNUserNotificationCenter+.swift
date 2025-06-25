//
//  UNUserNotificationCenter+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import UserNotifications


public enum UserNotificationsManager {
    static func requestNotification(
        category: NotificationCategory = .none,
        id: String = UUID().uuidString,
        title: String,
        body: String
    ) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        switch category {
        case let .manualRegister(runningData):
            let formatter = DateFormatter()
            
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            content.userInfo = [
                "id": runningData.id.uuidString,
                "date": formatter.string(from: runningData.date ?? .now),
                "distance": "\(runningData.distance)",
                "category": category.rawValue
            ]
        case .autoRegister, .none:
            break
        }
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        
        center.add(request)
    }
    
    public enum NotificationCategory: Hashable {
        case autoRegister(RunningData)
        case manualRegister(RunningData)
        case none
        
        public var rawValue: String {
            switch self {
            case .autoRegister:
                "AutoRegister"
            case .manualRegister:
                "ManualRegister"
            case .none:
                "None"
            }
        }
    }
}

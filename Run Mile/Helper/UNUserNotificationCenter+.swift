//
//  UNUserNotificationCenter+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import UserNotifications


extension UNUserNotificationCenter {
    static func requestNotification(id: String = UUID().uuidString, title: String, body: String) {
        let center = self.current()
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: id, content: content, trigger: nil)
        
        center.add(request)
    }
}

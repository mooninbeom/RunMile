//
//  UserNotificationPermissionService.swift
//  Run Mile
//
//  Created by Codex on 6/17/26.
//

import UserNotifications


actor UserNotificationPermissionService: NotificationPermissionService {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    /// 현재 앱의 알림 권한 상태를 Run Mile 도메인 상태로 변환해 반환합니다.
    func authorizationStatus() async -> NotificationPermissionStatus {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus.notificationPermissionStatus
    }

    /// 운동 완료 알림에 필요한 alert, badge, sound 권한을 요청합니다.
    func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .badge, .sound])
    }
}


private extension UNAuthorizationStatus {
    var notificationPermissionStatus: NotificationPermissionStatus {
        switch self {
        case .notDetermined:
            .notDetermined
        case .denied:
            .denied
        case .authorized:
            .authorized
        case .provisional:
            .provisional
        case .ephemeral:
            .ephemeral
        @unknown default:
            .unknown
        }
    }
}

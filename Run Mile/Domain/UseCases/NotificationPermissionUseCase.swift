//
//  NotificationPermissionUseCase.swift
//  Run Mile
//
//  Created by Codex on 6/17/26.
//

import Foundation


protocol NotificationPermissionUseCase: Sendable {
    func requestNotificationAuthorization() async throws
}


final class DefaultNotificationPermissionUseCase: NotificationPermissionUseCase {
    private let notificationPermissionService: NotificationPermissionService

    init(notificationPermissionService: NotificationPermissionService) {
        self.notificationPermissionService = notificationPermissionService
    }

    /// 운동 완료 알림을 받을 수 있도록 시스템 알림 권한을 요청합니다.
    func requestNotificationAuthorization() async throws {
        try await notificationPermissionService.requestAuthorization()
    }
}

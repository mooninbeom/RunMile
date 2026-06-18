//
//  NotificationPermissionService.swift
//  Run Mile
//
//  Created by Codex on 6/17/26.
//

import Foundation


enum NotificationPermissionStatus: Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
    case unknown
}


protocol NotificationPermissionService: Sendable {
    func authorizationStatus() async -> NotificationPermissionStatus

    @discardableResult
    func requestAuthorization() async throws -> Bool
}

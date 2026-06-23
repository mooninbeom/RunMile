//
//  MileageGoalNotificationService.swift
//  Run Mile
//
//  Created by Codex on 6/18/26.
//

import Foundation


protocol MileageGoalNotificationService: Sendable {
    /// 신발이 목표 마일리지에 도달했을 때 사용자에게 알림을 보냅니다.
    func requestGoalReachedNotification(shoes: Shoes) async
}

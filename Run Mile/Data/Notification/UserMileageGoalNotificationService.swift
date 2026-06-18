//
//  UserMileageGoalNotificationService.swift
//  Run Mile
//
//  Created by Codex on 6/18/26.
//

import Foundation


struct UserMileageGoalNotificationService: MileageGoalNotificationService {
    /// 목표 마일리지 달성 로컬 알림을 예약합니다.
    func requestGoalReachedNotification(shoes: Shoes) async {
        UserNotificationsManager.requestNotification(
            title: "\(shoes.nickname)의 목표 마일리지를 달성했습니다!",
            body: "축하드립니다! 이제 명예의 전당으로 갈 일만 남았습니다. 가보실까요?"
        )
    }
}

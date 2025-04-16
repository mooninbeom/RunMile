//
//  WorkoutDataRepository.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit


protocol WorkoutDataRepository: Sendable {
    /// 운동(러닝) 데이터를 불러옵니다.
    func fetchWorkoutData() async throws -> [RunningData]
}

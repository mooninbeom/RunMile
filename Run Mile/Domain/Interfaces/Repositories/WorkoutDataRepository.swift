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
    func fetchAllWorkoutData() async throws -> [Workout]
    
    ///
    func fetchUnsavedWorkoutData() async throws -> [Workout]
    
    /// 저장된 운동(러닝) 데이터를 불러옵니다.
    func fetchSavedWorkoutData() async throws -> [Workout]
}

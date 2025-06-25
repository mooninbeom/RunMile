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
    func fetchWorkoutData() async throws -> [Workout]
    
    /// 저장된 운동(러닝) 데이터를 불러옵니다.
    func fetchSavedWorkoutData() async throws -> [Workout]
    
    /// 운동(러닝) 데이터를 저장합니다. (등록된 운동 필터릴 용)
    func saveWorkoutData(workouts: [Workout]) async throws
    
    /// 운동(러닝) 데이터를 삭제합니다. (등록된 운동 필터릴 용)
    func deleteWorkoutDate(workouts: [Workout]) async throws
}

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
    
    /// 특정 운동의 세부 데이터(파워, 수직진폭, 지면 접촉 시간 등등)를 불러옵니다.
    func fetchDetailedWorkoutData(workout: HKWorkout, type: HKQuantityType) async throws -> [RunningMetricPoint]
}

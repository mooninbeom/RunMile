//
//  WorkoutDataRepository.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import HealthKit
import CoreLocation


protocol WorkoutDataRepository: Sendable {
    /// 운동(러닝) 데이터를 불러옵니다. (세부 데이터 제외)
    func fetchAllWorkoutData() async throws -> [Workout]
    
    /// 신발에 등록되지 않은 운동을 보여줍니다. (세부 데이터 제외)
    func fetchUnsavedWorkoutData() async throws -> [Workout]
    
    /// 저장된 운동(러닝) 데이터를 불러옵니다. (세부 데이터 제외)
    func fetchSavedWorkoutData() async throws -> [Workout]
    
    /// 단일 운동의 세부 데이터(파워, 수직진폭, 지면 접촉 시간 등등)를 불러옵니다. (내부 메소드)
    func fetchDetailedWorkoutData(workout: HKWorkout, type: HKQuantityType) async throws -> [RunningMetricPoint]
    
    /// (내부 메소드)
    func fetchSplits(workout: HKWorkout) async throws -> [SplitInfo]
    
    /// 거리별 PB 계산에 사용할 거리 샘플을 시간순으로 불러옵니다.
    func fetchDistanceSamples(workout: HKWorkout) async throws -> [WorkoutDistanceSample]
    
    /// 단일 운동의 운동 경로 데이터를 불러옵니다.
    func fetchDetailedWorkoutRouteData(workout: HKWorkout) async throws -> [CLLocation]
    
    /// 단일 운동의 데이터를 불러옵니다.(세부 데이터 포함)
    func fetchSingleWorkoutData(workout: HKWorkout) async throws -> WorkoutDetailData
}

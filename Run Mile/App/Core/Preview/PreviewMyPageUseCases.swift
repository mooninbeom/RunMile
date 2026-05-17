//
//  PreviewMyPageUseCases.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import Foundation


struct PreviewMyPageUseCase: MyPageUseCase {
    /// Preview에서는 메일 작성 가능 상태로 고정해 문의 화면 노출을 확인할 수 있게 합니다.
    func evaluateMailAvailable() -> Bool {
        true
    }
}


struct PreviewHOFUseCase: HOFUseCase {
    /// 명예의 전당 Preview에 사용할 졸업 신발 목록을 반환합니다.
    func fetchShoes() async throws -> [Shoes] {
        PreviewShoesMockData.hallOfFameShoes
    }
    
    /// Preview에서 앱 전체 PB 비교에 사용할 러닝 샘플을 반환합니다.
    func fetchAllRunningWorkouts() async throws -> [Workout] {
        PreviewShoesMockData.workouts
    }
    
    /// Preview에서는 HealthKit 상세 샘플 대신 샘플 운동의 평균 페이스로 시각 확인용 기록을 구성합니다.
    func fetchDistanceRecords(for workouts: [Workout]) async -> [WorkoutDistanceRecord] {
        workouts.flatMap { workout in
            WorkoutDistanceRecordTarget.allCases.compactMap { target in
                guard workout.distance >= target.meters,
                      workout.distance > 0,
                      workout.time > 0 else {
                    return nil
                }
                
                let duration = workout.time * target.meters / workout.distance
                return WorkoutDistanceRecord(
                    workoutID: workout.id,
                    target: target,
                    duration: duration,
                    workoutDate: workout.date,
                    segmentStartDate: workout.workout.startDate,
                    segmentEndDate: workout.workout.startDate.addingTimeInterval(duration),
                    sourceWorkoutDistance: workout.distance
                )
            }
        }
    }
}
#endif

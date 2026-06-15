//
//  PreviewWorkoutUseCases.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import CoreLocation
import Foundation


struct PreviewHealthDataUseCase: HealthDataUseCase {
    /// Preview에서는 HealthKit 권한 요청 없이 바로 데이터를 표시합니다.
    func checkHealthAuthorization() async throws -> Bool {
        false
    }

    /// 운동 목록 Preview에 사용할 샘플 운동 데이터를 반환합니다.
    func fetchWorkoutData() async throws -> [Workout] {
        PreviewShoesMockData.workouts
    }

    /// 운동 목록 Preview에 사용할 운동-신발 등록 정보를 반환합니다.
    func fetchWorkoutShoeNames() async throws -> [UUID: String] {
        PreviewWorkoutMockData.workoutShoeNames
    }
}


struct PreviewWorkoutDetailUseCase: WorkoutDetailUseCase {
    /// 운동 상세 Preview에 사용할 차트, 구간, 경로 데이터를 반환합니다.
    func fetchWorkoutDetailData(
        workout: Workout,
        samplingCount: Int
    ) async throws -> WorkoutDetailData {
        PreviewWorkoutMockData.detail
    }

    /// Preview 데이터는 이미 표시용으로 적당히 줄어든 상태라 원본을 반환합니다.
    func downsampling(
        samples: [UnifiedWorkoutDetailData],
        targetCount: Int
    ) -> [UnifiedWorkoutDetailData] {
        samples
    }

    /// Preview 지도에 사용할 페이스 구간을 위치 배열 기반으로 간단히 생성합니다.
    func buildRouteSegments(
        locations: [CLLocation],
        runningPace: [UnifiedWorkoutDetailData],
        workoutStartDate: Date
    ) -> [WorkoutRouteSegment] {
        guard locations.count >= 2 else { return [] }

        return zip(locations, locations.dropFirst()).enumerated().map { index, pair in
            let ratio = Double(index) / Double(max(locations.count - 2, 1))
            return WorkoutRouteSegment(
                coordinates: [pair.0.coordinate, pair.1.coordinate],
                averageSpeed: 2.8 + ratio * 0.55,
                paceRatio: ratio
            )
        }
    }
}


struct PreviewChooseShoesUseCase: ChooseShoesUseCase {
    /// 신발 선택 Preview에 사용할 샘플 신발 목록을 반환합니다.
    func fetchShoesList() async throws -> [Shoes] {
        PreviewShoesMockData.shoes
    }

    /// Preview에서는 이미 등록된 운동 충돌이 없는 상태로 표시합니다.
    func registeredWorkoutConflictCount(targetShoes: Shoes, workouts: [Workout]) async throws -> Int {
        0
    }

    /// Preview에서는 저장소를 변경하지 않고 등록 완료 흐름만 통과시킵니다.
    func registerWorkouts(
        shoes: Shoes,
        workouts: [Workout],
        shouldMoveRegisteredWorkouts: Bool
    ) async throws {}
}


struct PreviewAddMileageShoesUseCase: AddMileageShoesUseCase {
    private let selectedShoesId: UUID? = PreviewShoesMockData.shoes.first?.id

    /// 자동 등록 Preview에 사용할 샘플 신발 목록을 반환합니다.
    func fetchAllShoes() async throws -> [Shoes] {
        PreviewShoesMockData.shoes
    }

    /// 자동 등록 Preview에서 선택된 신발 ID를 반환합니다.
    func fetchCurrentSelectedSheos() -> UUID? {
        selectedShoesId
    }

    /// Preview에서는 UserDefaults를 변경하지 않습니다.
    func setCurrentSelectedShoes(id: UUID?) {}
}
#endif

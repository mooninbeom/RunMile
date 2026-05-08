//
//  ShoesListUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


protocol ShoesListUseCase {
    func fetchShoes() async throws -> [Shoes]
    func fetchMonthlyRunningDistance() async throws -> Double
}


final class DefaultShoesViewUseCase: ShoesListUseCase {
    let repository: ShoesDataRepository
    let workoutRepository: WorkoutDataRepository
    
    init(
        repository: ShoesDataRepository,
        workoutRepository: WorkoutDataRepository
    ) {
        self.repository = repository
        self.workoutRepository = workoutRepository
    }
    
    public func fetchShoes() async throws -> [Shoes] {
        try await repository.fetchCurrentShoes()
    }
    
    /// 전체 러닝 운동 중 현재 달에 해당하는 운동 거리 합계를 km 단위로 반환합니다.
    public func fetchMonthlyRunningDistance() async throws -> Double {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: Date()) else {
            return 0
        }
        
        let workouts = try await workoutRepository.fetchAllWorkoutData()
        let distanceInMeters = workouts.reduce(0.0) { total, workout in
            guard monthInterval.contains(workout.date) else { return total }
            return total + workout.distance
        }
        
        return distanceInMeters / 1000
    }
}

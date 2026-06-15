//
//  ChooseShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation


protocol ChooseShoesUseCase: Sendable {
    func fetchShoesList() async throws -> [Shoes]
    func registeredWorkoutConflictCount(targetShoes: Shoes, workouts: [Workout]) async throws -> Int
    func registerWorkouts(shoes: Shoes, workouts: [Workout], shouldMoveRegisteredWorkouts: Bool) async throws
}



final class DefaultChooseShoesUseCase: ChooseShoesUseCase {
    private let repository: ShoesDataRepository

    init(repository: ShoesDataRepository) {
        self.repository = repository
    }

    public func fetchShoesList() async throws -> [Shoes] {
        try await repository.fetchCurrentShoes()
    }

    /// 선택한 운동 중 다른 신발에 이미 등록된 운동 개수를 반환합니다.
    public func registeredWorkoutConflictCount(targetShoes: Shoes, workouts: [Workout]) async throws -> Int {
        let allShoes = try await repository.fetchAllShoes()
        let workoutIDs = Set(workouts.map(\.id))
        let conflictIDs = Self.registeredWorkoutConflictIDs(
            targetShoesID: targetShoes.id,
            workoutIDs: workoutIDs,
            shoes: allShoes
        )

        return conflictIDs.count
    }

    /// 운동을 선택 신발에 등록하고, 필요하면 다른 신발에 등록된 운동을 선택 신발로 이동합니다.
    public func registerWorkouts(
        shoes: Shoes,
        workouts: [Workout],
        shouldMoveRegisteredWorkouts: Bool
    ) async throws {
        let allShoes = try await repository.fetchAllShoes()
        let targetShoes = allShoes.first(where: { $0.id == shoes.id }) ?? shoes
        let workoutIDs = Set(workouts.map(\.id))
        let conflictIDs = Self.registeredWorkoutConflictIDs(
            targetShoesID: shoes.id,
            workoutIDs: workoutIDs,
            shoes: allShoes
        )

        let registerableWorkoutIDs = shouldMoveRegisteredWorkouts ? workoutIDs : workoutIDs.subtracting(conflictIDs)
        let registerableWorkouts = workouts.filter { registerableWorkoutIDs.contains($0.id) }
        guard !registerableWorkouts.isEmpty else {
            return
        }

        try await repository.registerWorkouts(
            shoes: targetShoes,
            workouts: registerableWorkouts,
            shouldMoveRegisteredWorkouts: shouldMoveRegisteredWorkouts
        )
    }

    private static func registeredWorkoutConflictIDs(
        targetShoesID: UUID,
        workoutIDs: Set<UUID>,
        shoes: [Shoes]
    ) -> Set<UUID> {
        var conflictIDs = Set<UUID>()

        for shoe in shoes where shoe.id != targetShoesID {
            let registeredWorkoutIDs = Set(shoe.workouts.map(\.id))
            conflictIDs.formUnion(workoutIDs.intersection(registeredWorkoutIDs))
        }

        return conflictIDs
    }
}

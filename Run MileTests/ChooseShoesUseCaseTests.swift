//
//  ChooseShoesUseCaseTests.swift
//  Run MileTests
//
//  Created by Codex on 6/14/26.
//

import Foundation
import HealthKit
import Testing
@testable import Run_Mile


struct ChooseShoesUseCaseTests {
    @Test func conflictCountIncludesWorkoutsRegisteredToOtherShoes() async throws {
        let workout = makeWorkout()
        let firstShoes = makeShoes(nickname: "이전 신발", workouts: [workout])
        let targetShoes = makeShoes(nickname: "새 신발")
        let repository = FakeChooseShoesRepository(shoes: [firstShoes, targetShoes])
        let useCase = makeUseCase(repository: repository)

        let conflictCount = try await useCase.registeredWorkoutConflictCount(
            targetShoes: targetShoes,
            workouts: [workout]
        )

        #expect(conflictCount == 1)
    }

    @Test func registerWorkoutsMovesRegisteredWorkoutToTargetShoes() async throws {
        let workout = makeWorkout()
        let firstShoes = makeShoes(nickname: "이전 신발", workouts: [workout])
        let targetShoes = makeShoes(nickname: "새 신발")
        let repository = FakeChooseShoesRepository(shoes: [firstShoes, targetShoes])
        let useCase = makeUseCase(repository: repository)

        try await useCase.registerWorkouts(
            shoes: targetShoes,
            workouts: [workout],
            shouldMoveRegisteredWorkouts: true
        )

        let shoes = try await repository.fetchAllShoes()
        let updatedFirstShoes = try #require(shoes.first(where: { $0.id == firstShoes.id }))
        let updatedTargetShoes = try #require(shoes.first(where: { $0.id == targetShoes.id }))

        #expect(updatedFirstShoes.workouts.isEmpty)
        #expect(updatedTargetShoes.workouts.map(\.id) == [workout.id])
    }

    @Test func registerWorkoutsDoesNotDuplicateExistingTargetWorkout() async throws {
        let workout = makeWorkout()
        let targetShoes = makeShoes(nickname: "현재 신발", workouts: [workout])
        let repository = FakeChooseShoesRepository(shoes: [targetShoes])
        let useCase = makeUseCase(repository: repository)

        try await useCase.registerWorkouts(
            shoes: targetShoes,
            workouts: [workout],
            shouldMoveRegisteredWorkouts: false
        )

        let shoes = try await repository.fetchAllShoes()
        let updatedTargetShoes = try #require(shoes.first(where: { $0.id == targetShoes.id }))

        #expect(updatedTargetShoes.workouts.map(\.id) == [workout.id])
    }

    @Test func registerWorkoutsWithoutMoveDoesNotDuplicateOtherShoesWorkout() async throws {
        let workout = makeWorkout()
        let firstShoes = makeShoes(nickname: "이전 신발", workouts: [workout])
        let targetShoes = makeShoes(nickname: "새 신발")
        let repository = FakeChooseShoesRepository(shoes: [firstShoes, targetShoes])
        let useCase = makeUseCase(repository: repository)

        try await useCase.registerWorkouts(
            shoes: targetShoes,
            workouts: [workout],
            shouldMoveRegisteredWorkouts: false
        )

        let shoes = try await repository.fetchAllShoes()
        let updatedFirstShoes = try #require(shoes.first(where: { $0.id == firstShoes.id }))
        let updatedTargetShoes = try #require(shoes.first(where: { $0.id == targetShoes.id }))

        #expect(updatedFirstShoes.workouts.map(\.id) == [workout.id])
        #expect(updatedTargetShoes.workouts.isEmpty)
    }
}


private func makeUseCase(repository: ShoesDataRepository) -> DefaultChooseShoesUseCase {
    DefaultChooseShoesUseCase(
        repository: repository,
        mileageGoalNotificationService: FakeMileageGoalNotificationService()
    )
}


private actor FakeChooseShoesRepository: ShoesDataRepository {
    private var shoes: [Shoes]

    init(shoes: [Shoes]) {
        self.shoes = shoes
    }

    func fetchAllShoes() async throws -> [Shoes] {
        shoes
    }

    func fetchHOFShoes() async throws -> [Shoes] {
        shoes.filter(\.isGradutate)
    }

    func fetchCurrentShoes() async throws -> [Shoes] {
        shoes.filter { !$0.isGradutate }
    }

    func fetchSingleShoes(id: UUID) async throws -> Shoes {
        guard let shoe = shoes.first(where: { $0.id == id }) else {
            throw FakeChooseShoesRepositoryError.shoesNotFound
        }
        return shoe
    }

    func createShoes(shoes: Shoes) async throws {
        self.shoes.append(shoes)
    }

    func updateShoes(shoes: Shoes) async throws {
        guard let index = self.shoes.firstIndex(where: { $0.id == shoes.id }) else {
            throw FakeChooseShoesRepositoryError.shoesNotFound
        }
        self.shoes[index] = shoes
    }

    func registerWorkouts(
        shoes: Shoes,
        workouts: [Workout],
        shouldMoveRegisteredWorkouts: Bool
    ) async throws {
        guard let targetIndex = self.shoes.firstIndex(where: { $0.id == shoes.id }) else {
            throw FakeChooseShoesRepositoryError.shoesNotFound
        }

        let workoutIDs = Set(workouts.map(\.id))

        if shouldMoveRegisteredWorkouts {
            for index in self.shoes.indices where self.shoes[index].id != shoes.id {
                let remainingWorkouts = self.shoes[index].workouts.filter { !workoutIDs.contains($0.id) }
                self.shoes[index] = self.shoes[index].replacingWorkouts(remainingWorkouts)
            }
        }

        let existingWorkoutIDs = Set(self.shoes[targetIndex].workouts.map(\.id))
        let newWorkouts = workouts.filter { !existingWorkoutIDs.contains($0.id) }
        self.shoes[targetIndex] = self.shoes[targetIndex].replacingWorkouts(
            self.shoes[targetIndex].workouts + newWorkouts
        )
    }

    func deleteShoes(shoes: Shoes) async throws {
        self.shoes.removeAll { $0.id == shoes.id }
    }

    func updateSelectedShoes(shoes: Shoes) async {}
}


private actor FakeMileageGoalNotificationService: MileageGoalNotificationService {
    private(set) var requestedShoes: [Shoes] = []

    func requestGoalReachedNotification(shoes: Shoes) async {
        requestedShoes.append(shoes)
    }
}


private enum FakeChooseShoesRepositoryError: Error {
    case shoesNotFound
}


private extension Shoes {
    func replacingWorkouts(_ workouts: [Workout]) -> Shoes {
        Shoes(
            id: id,
            image: image,
            shoesName: shoesName,
            nickname: nickname,
            goalMileage: goalMileage,
            currentMileage: currentMileage,
            workouts: workouts,
            isGraduate: isGradutate
        )
    }
}


private func makeShoes(
    nickname: String,
    workouts: [Workout] = []
) -> Shoes {
    Shoes(
        id: UUID(),
        image: Data(),
        shoesName: "Adidas 아디스타 4",
        nickname: nickname,
        goalMileage: 800,
        currentMileage: 0,
        workouts: workouts
    )
}


private func makeWorkout(
    distance: Double = 5000,
    duration: TimeInterval = 1800
) -> Workout {
    let startDate = Date(timeIntervalSince1970: 0)
    let endDate = startDate.addingTimeInterval(duration)
    let healthWorkout = HKWorkout(
        activityType: .running,
        start: startDate,
        end: endDate,
        duration: duration,
        totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: 300),
        totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
        metadata: nil
    )

    return Workout(workout: healthWorkout)
}

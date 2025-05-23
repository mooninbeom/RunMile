//
//  ChooseShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation


protocol ChooseShoesUseCase: Sendable {
    func fetchShoesList() async throws -> [Shoes]
    func registerWorkout(shoes: Shoes, workout: RunningData) async throws
}



final class DefaultChooseShoesUseCase: ChooseShoesUseCase {
    private let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    public func fetchShoesList() async throws -> [Shoes] {
        try await repository.fetchCurrentShoes()
    }
    
    public func registerWorkout(shoes: Shoes, workout: RunningData) async throws {
        var newWorkouts = shoes.workouts
        newWorkouts.append(workout)
        
        let newShoes = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: shoes.goalMileage,
            currentMileage: shoes.currentMileage,
            workouts: newWorkouts
        )
        
        try await repository.updateShoes(shoes: newShoes)
    }
    
    
}

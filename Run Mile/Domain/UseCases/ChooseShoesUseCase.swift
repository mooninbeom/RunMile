//
//  ChooseShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation


protocol ChooseShoesUseCase: Sendable {
    func fetchShoesList() async throws -> [Shoes]
    func registerWorkouts(shoes: Shoes, workouts: [Workout]) async throws
}



final class DefaultChooseShoesUseCase: ChooseShoesUseCase {
    private let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    public func fetchShoesList() async throws -> [Shoes] {
        try await repository.fetchCurrentShoes()
    }
    
    public func registerWorkouts(shoes: Shoes, workouts: [Workout]) async throws {
        var newWorkouts = shoes.workouts
        newWorkouts.append(contentsOf: workouts)
        
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

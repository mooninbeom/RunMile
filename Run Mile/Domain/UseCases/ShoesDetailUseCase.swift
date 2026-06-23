//
//  ShoesDetailUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


protocol ShoesDetailUseCase {
    func editShoes(shoes: Shoes) async throws
    func deleteShoes(shoes: Shoes) async throws
    func graduateShoes(shoes: Shoes) async throws
}


final class DefaultShoesDetailUseCase: ShoesDetailUseCase {
    let repository: ShoesDataRepository
    private let mileageGoalNotificationService: MileageGoalNotificationService
    
    init(
        repository: ShoesDataRepository,
        mileageGoalNotificationService: MileageGoalNotificationService
    ) {
        self.repository = repository
        self.mileageGoalNotificationService = mileageGoalNotificationService
    }
    
    public func editShoes(shoes: Shoes) async throws {
        let previousShoes = try await repository.fetchSingleShoes(id: shoes.id)
        let previousMileage = previousShoes.totalMileage
        try await repository.updateShoes(shoes: shoes)
        let updatedShoes = try await repository.fetchSingleShoes(id: shoes.id)
        if updatedShoes.didReachGoal(from: previousMileage) {
            await mileageGoalNotificationService.requestGoalReachedNotification(shoes: updatedShoes)
        }
    }
    
    public func deleteShoes(shoes: Shoes) async throws {
        try await repository.deleteShoes(shoes: shoes)
        await repository.updateSelectedShoes(shoes: shoes)
    }
    
    public func graduateShoes(shoes: Shoes) async throws {
        try await repository.updateShoes(shoes: shoes)
        await repository.updateSelectedShoes(shoes: shoes)
    }
}

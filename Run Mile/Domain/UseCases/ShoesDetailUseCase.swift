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
    func normalizeImage(from imageData: Data) async throws -> Data
    func removeImageBackground(from imageData: Data) async throws -> Data
}


final class DefaultShoesDetailUseCase: ShoesDetailUseCase {
    let repository: ShoesDataRepository
    private let mileageGoalNotificationService: MileageGoalNotificationService
    private let imageProcessingService: ShoeImageProcessingService
    
    init(
        repository: ShoesDataRepository,
        mileageGoalNotificationService: MileageGoalNotificationService,
        imageProcessingService: ShoeImageProcessingService
    ) {
        self.repository = repository
        self.mileageGoalNotificationService = mileageGoalNotificationService
        self.imageProcessingService = imageProcessingService
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

    public func normalizeImage(from imageData: Data) async throws -> Data {
        try await imageProcessingService.normalizeImage(from: imageData)
    }

    public func removeImageBackground(from imageData: Data) async throws -> Data {
        try await imageProcessingService.removeBackground(from: imageData)
    }
}

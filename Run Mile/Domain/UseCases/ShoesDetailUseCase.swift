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
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    public func editShoes(shoes: Shoes) async throws {
        try await repository.updateShoes(shoes: shoes)
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

//
//  ShoesDetailUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


protocol ShoesDetailUseCase {
    func editShoes(shoes: Shoes) async throws
}


final class DefaultShoesDetailUseCase: ShoesDetailUseCase {
    let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    public func editShoes(shoes: Shoes) async throws {
        try await repository.updateShoes(shoes: shoes)
    }
}

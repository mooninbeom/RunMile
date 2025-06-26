//
//  ShoesListUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


protocol ShoesListUseCase {
    func fetchShoes() async throws -> [Shoes]
}


final class DefaultShoesViewUseCase: ShoesListUseCase {
    let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    public func fetchShoes() async throws -> [Shoes] {
        try await repository.fetchCurrentShoes()
    }
}

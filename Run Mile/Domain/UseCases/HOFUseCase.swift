//
//  HOFUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import Foundation


protocol HOFUseCase: Sendable {
    func fetchShoes() async throws -> [Shoes]
}


final class DefaultHOFUseCase: HOFUseCase {
    private let repository: ShoesDataRepository
    
    init(repository: ShoesDataRepository) {
        self.repository = repository
    }
    
    func fetchShoes() async throws -> [Shoes] {
        try await repository.fetchHOFShoes()
    }
}

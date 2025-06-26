//
//  AddMileageShoesUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 5/12/25.
//

import Foundation


protocol AddMileageShoesUseCase: Sendable {
    func fetchAllShoes() async throws -> [Shoes]
    func fetchCurrentSelectedSheos() -> UUID?
    func setCurrentSelectedShoes(id: UUID?)
}



final class DefaultAddMileageShoesUseCase: AddMileageShoesUseCase {
    private let shoesRepository: ShoesDataRepository
    
    init(shoesRepository: ShoesDataRepository) {
        self.shoesRepository = shoesRepository
    }
    
    func fetchAllShoes() async throws -> [Shoes] {
        try await shoesRepository.fetchCurrentShoes()
    }
    
    func fetchCurrentSelectedSheos() -> UUID? {
        if let id = UUID(uuidString: UserDefaults.standard.selectedShoesID) {
            return id
        }
        return nil
    }
    
    func setCurrentSelectedShoes(id: UUID?) {
        if let id = id?.uuidString {
            UserDefaults.standard.selectedShoesID = id
        } else {
            UserDefaults.standard.selectedShoesID = ""
        }
    }
}

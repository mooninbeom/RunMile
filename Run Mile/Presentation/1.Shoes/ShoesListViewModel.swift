//
//  ShoesListViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class ShoesListViewModel {
    public var shoes: [Shoes] = []
    
    
    let useCase: ShoesListUseCase
    
    init(useCase: ShoesListUseCase) {
        self.useCase = useCase
    }
}


extension ShoesListViewModel {
    @MainActor
    public func addShoesButtonTapped() {
        NavigationCoordinator.shared.push(.addShoes)
    }
    
    public func onAppear() {
        Task {
            do {
                let result = try await self.useCase.fetchShoes()
                self.shoes = result
            } catch {
                
            }
        }
    }
}

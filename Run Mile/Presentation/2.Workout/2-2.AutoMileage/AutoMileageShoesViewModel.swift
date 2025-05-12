//
//  AutoMileageShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/11/25.
//

import Foundation


@Observable
final class AutoMileageShoesViewModel {
    public var selectedShoesId: UUID?
}

extension AutoMileageShoesViewModel {
    @MainActor
    public func cancelButtonTapped() {
        NavigationCoordinator.shared.dismissSheet()
    }
    
    @MainActor
    public func saveButtonTapped() {
        
    }
    
    @MainActor
    public func shoesCellTapped(shoes: Shoes) {
        self.selectedShoesId = shoes.id
    }
}

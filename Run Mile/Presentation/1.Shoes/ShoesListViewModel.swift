//
//  ShoesListViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class ShoesListViewModel {
    
}


extension ShoesListViewModel {
    @MainActor
    public func addShoesButtonTapped() {
        NavigationCoordinator.shared.push(.addShoes)
    }
}

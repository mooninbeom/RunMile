//
//  ShoesListViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


final class ShoesListViewModel: ObservableObject {
    
}


extension ShoesListViewModel {
    @MainActor
    public func addShoesButtonTapped() {
        NavigationCoordinator.shared.push(.addShoes)
    }
}

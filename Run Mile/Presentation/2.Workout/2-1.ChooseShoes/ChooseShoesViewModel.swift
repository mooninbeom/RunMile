//
//  ChooseShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


final class ChooseShoesViewModel: ObservableObject {
    
}


extension ChooseShoesViewModel {
    @MainActor
    public func cancelButtonTapped() {
        NavigationCoordinator.shared.dismissSheet()
    }
}

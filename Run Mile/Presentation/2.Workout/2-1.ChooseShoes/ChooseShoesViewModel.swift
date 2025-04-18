//
//  ChooseShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation

@Observable
final class ChooseShoesViewModel {
    
}


extension ChooseShoesViewModel {
    @MainActor
    public func cancelButtonTapped() {
        NavigationCoordinator.shared.dismissSheet()
    }
    
    @MainActor
    public func shoesCellTapped() {
//        let alert = AlertData(
//            title: "추가하시겠습니까?",
//            message: nil,
//            firstButton: .cancel {
//                
//            },
//            secondButton: .ok {
//                
//            }
//        )
//        
//        NavigationCoordinator.shared.push(alert)
    }
}

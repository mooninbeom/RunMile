//
//  HOFShoesDetailViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import Foundation


@Observable
final class HOFShoesDetailViewModel {
    public let shoes: Shoes
    
    init(shoes: Shoes) {
        self.shoes = shoes
    }
}


extension HOFShoesDetailViewModel {
    @MainActor
    public func imageTapped() {
        NavigationCoordinator.shared.push(.imageDetail(shoes.image), tab: .myPage)
    }
}

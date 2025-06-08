//
//  HOFViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import Foundation


@Observable
final class HOFViewModel {
    public var shoes: [Shoes] = []
    
    
    private let useCase: HOFUseCase
    
    init(useCase: HOFUseCase) {
        self.useCase = useCase
    }
}


extension HOFViewModel {
    @MainActor
    public func onAppear() async {
        do {
            self.shoes = try await self.useCase.fetchShoes()
        } catch {
            // TODO: Error Handling
        }
    }
    
    @MainActor
    public func shoesCellTapped(shoes: Shoes) {
        NavigationCoordinator.shared
            .push(.hofShoesDetail(shoes), tab: .myPage)
    }
}

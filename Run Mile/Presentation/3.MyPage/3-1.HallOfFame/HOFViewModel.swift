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
            NavigationCoordinator.shared.push(.init(
                title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n\(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }
    }
    
    @MainActor
    public func shoesCellTapped(shoes: Shoes) {
        NavigationCoordinator.shared
            .push(.hofShoesDetail(shoes), tab: .myPage)
    }
}

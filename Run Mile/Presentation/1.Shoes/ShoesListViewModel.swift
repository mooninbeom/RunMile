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
    public var monthlyDistanceText: String = "0.0 km"
    
    
    let useCase: ShoesListUseCase
    
    init(useCase: ShoesListUseCase) {
        self.useCase = useCase
    }
    
    public var shoeCardItems: [ShoePresentationInfo] {
        shoes.map { ShoePresentationInfo(shoe: $0) }
    }
}


extension ShoesListViewModel {
    @MainActor
    public func addShoesButtonTapped() {
        NavigationCoordinator.shared.push(.addShoes {
            self.onAppear()
        })
    }
    
    @MainActor
    public func shoesCellTapped(_ shoes: Shoes) {
        NavigationCoordinator.shared
            .push(.shoesDetail(shoes), tab: .shoes)
    }
    
    public func onAppear() {
        Task {
            do {
                async let shoes = useCase.fetchShoes()
                async let monthlyDistance = useCase.fetchMonthlyRunningDistance()
                
                self.shoes = try await shoes
                self.monthlyDistanceText = String(format: "%.1f km", try await monthlyDistance)
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
}

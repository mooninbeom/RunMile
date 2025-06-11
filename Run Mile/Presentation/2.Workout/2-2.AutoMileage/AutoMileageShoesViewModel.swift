//
//  AutoMileageShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 5/11/25.
//

import Foundation


@Observable
final class AutoMileageShoesViewModel {
    public var shoes: [Shoes] = []
    public var selectedShoesId: UUID?
    public var isSaveButtonDisabled: Bool {
        selectedShoesId == existingSelectedShoesId
    }
    
    private let existingSelectedShoesId: UUID?
    
    private let useCase: AddMileageShoesUseCase
    
    init(useCase: AddMileageShoesUseCase) {
        self.useCase = useCase
        
        let id = useCase.fetchCurrentSelectedSheos()
        self.selectedShoesId = id
        self.existingSelectedShoesId = id
    }
}

extension AutoMileageShoesViewModel {
    @MainActor
    public func onAppear() async {
        do {
            self.shoes = try await useCase.fetchAllShoes()
        } catch {
            NavigationCoordinator.shared.push(.init(
                title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }
    }
    
    @MainActor
    public func cancelButtonTapped() {
        NavigationCoordinator.shared.dismissSheet()
    }
    
    @MainActor
    public func saveButtonTapped() {
        useCase.setCurrentSelectedShoes(id: selectedShoesId)
        NavigationCoordinator.shared.dismissSheet()
    }
    
    @MainActor
    public func shoesCellTapped(shoes: Shoes) {
        if shoes.id == self.selectedShoesId {
            self.selectedShoesId = nil
        } else {
            self.selectedShoesId = shoes.id
        }
    }
}

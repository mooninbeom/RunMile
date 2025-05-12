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
            // TODO: Error handling
            print(error)
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

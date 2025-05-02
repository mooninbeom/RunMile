//
//  ChooseShoesViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation

@Observable
final class ChooseShoesViewModel {
    private let useCase: ChooseShoesUseCase
    private let workout: RunningData
    
    public var shoes: [Shoes] = []
    
    init(useCase: ChooseShoesUseCase, workout: RunningData) {
        self.useCase = useCase
        self.workout = workout
    }
}


extension ChooseShoesViewModel {
    @MainActor
    public func onAppear() async {
        do {
            self.shoes = try await useCase.fetchShoesList()
        } catch {
            // TODO: Error handle
            print(#function)
        }
    }
    
    @MainActor
    public func cancelButtonTapped() {
        NavigationCoordinator.shared.dismissSheet()
    }
    
    @MainActor
    public func shoesCellTapped(shoes: Shoes) {
        Task {
            do {
                try await useCase.registerWorkout(shoes: shoes, workout: workout)
                cancelButtonTapped()
            } catch {
                
            }
        }
    }
}

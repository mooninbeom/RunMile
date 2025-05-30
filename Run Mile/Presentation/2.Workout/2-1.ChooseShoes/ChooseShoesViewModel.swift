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
    private let workouts: [RunningData]
    
    public var shoes: [Shoes] = []
    
    init(
        useCase: ChooseShoesUseCase,
        workouts: [RunningData]
    ) {
        self.useCase = useCase
        self.workouts = workouts
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
                try await useCase.registerWorkouts(shoes: shoes, workouts: workouts)
                cancelButtonTapped()
            } catch {
                // TODO: Error Handling
                print(error)
            }
        }
    }
}

//
//  WorkoutViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation

@Observable
final class WorkoutListViewModel {
    private let useCase: HealthDataUseCase
    
    public var workouts: [RunningData] = []
    
    init(useCase: HealthDataUseCase) {
        self.useCase = useCase
    }
    
}



extension WorkoutListViewModel {
    public func onAppear() async {
        do {
            if try await useCase.checkHealthAuthorization() {
                self.workouts = try await useCase.fetchWorkoutData()
            }
        } catch {
            // TODO: 에러 대응
            print(#function)
        }
    }
    
    
    @MainActor
    public func workoutCellTapped() {
        NavigationCoordinator.shared.push(.chooseShoes)
    }
}

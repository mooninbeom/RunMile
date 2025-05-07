//
//  WorkoutViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation
import SwiftUICore

@Observable
final class WorkoutListViewModel {
    private let useCase: HealthDataUseCase
    
    public var workouts: [RunningData] = []
    public var viewStatus: ViewStatus = .none
    
    init(useCase: HealthDataUseCase) {
        self.useCase = useCase
    }
    
    enum ViewStatus {
        case none
        case loading
        case empty
    }
}



extension WorkoutListViewModel {
    @MainActor
    public func onAppear() async {
        self.viewStatus = .loading
        
        do {
            let isRequested = try await useCase.checkHealthAuthorization()
            let workouts = try await useCase.fetchWorkoutData()
            
            if !isRequested, workouts.isEmpty {
                self.viewStatus = .empty
                return
            }
            self.workouts = workouts
            self.viewStatus = .none
            
            await AppDelegate.setHealthBackgroundTask()
        } catch {
            // TODO: 에러 대응
            print(error)
        }
    }
    
    @MainActor
    public func workoutNotVisibleButtonTapped() {
//        NavigationCoordinator.shared.switchAndPush(.myPage, tab: .myPage)
    }
    
    @MainActor
    public func workoutCellTapped(workout: RunningData) {
        NavigationCoordinator.shared.push(.chooseShoes(workout))
    }
}

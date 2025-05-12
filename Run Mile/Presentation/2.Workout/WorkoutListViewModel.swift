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
    
    public var dateHeaders: [String] = []
    public var workouts: [[RunningData]] = []
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
            self.viewStatus = .none
            
            self.classifyWorkoutsByDate(workouts: workouts)
            
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
    
    @MainActor
    public func automaticRegisterButtonTapped() {
        NavigationCoordinator.shared.push(.automaticRegister)
    }
}


extension WorkoutListViewModel {
    private func classifyWorkoutsByDate(workouts: [RunningData]) {
        var resultWorkouts = [RunningData]()
        
        for workout in workouts {
            if dateHeaders.isEmpty {
                dateHeaders.append(workout.date!.yearMonth)
                resultWorkouts.append(workout)
                continue
            }
            
            let currentDate = workout.date!.yearMonth
            
            if currentDate != dateHeaders.last! {
                self.workouts.append(resultWorkouts)
                resultWorkouts.removeAll()
                
                dateHeaders.append(currentDate)
                resultWorkouts.append(workout)
                continue
            }
            
            resultWorkouts.append(workout)
        }
        
        if !resultWorkouts.isEmpty {
            self.workouts.append(resultWorkouts)
        }
    }
}

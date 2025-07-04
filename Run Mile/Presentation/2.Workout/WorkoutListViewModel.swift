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
    public var workouts: [[Workout]] = []
    public var viewStatus: ViewStatus = .none
    
    public var selectedWorkout: Set<UUID> = []
    
    init(useCase: HealthDataUseCase) {
        self.useCase = useCase
    }
    
    enum ViewStatus {
        case none
        case loading
        case empty
        case selection
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
            
            await AppDelegate.setBackgroundDelivery()
        } catch {
            if let error = error as? HealthError,
               error == .unknownError || error == .notAvailableDevice {
                NavigationCoordinator.shared.push(.init(
                    title: "권한 부여 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            } else {
                NavigationCoordinator.shared.push(.init(
                    title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
    
    @MainActor
    public func workoutNotVisibleButtonTapped() {
        NavigationCoordinator.shared.switchAndPush(.fitnessConnect, tab: .myPage)
    }
    
    @MainActor
    public func workoutCellTapped(workout: Workout) {
        if case .selection = self.viewStatus {
            let id = workout.id
            
            if self.selectedWorkout.contains(id) {
                self.selectedWorkout.remove(id)
            } else {
                self.selectedWorkout.insert(id)
            }
        } else {
            NavigationCoordinator.shared.push(.chooseShoes([workout], {
                Task {
                    do {
                        let workouts = try await self.useCase.fetchWorkoutData()
                        self.classifyWorkoutsByDate(workouts: workouts)
                    } catch {
                        NavigationCoordinator.shared.push(.init(
                            title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                            message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                            firstButton: .cancel(title: "확인", action: {}),
                            secondButton: nil
                        ))
                    }
                }
            }))
        }
    }
    
    @MainActor
    public func automaticRegisterButtonTapped() {
        NavigationCoordinator.shared.push(.automaticRegister)
    }
    
    @MainActor
    public func selectionButtonTapped() {
        self.viewStatus = .selection
    }
    
    @MainActor
    public func saveSelectedWorkoutsButtonTapped() {
        let workouts = self.workouts
            .flatMap { $0 }
            .filter { self.selectedWorkout.contains($0.id) }
        
        NavigationCoordinator.shared.push(.chooseShoes(workouts, {
            Task {
                self.selectedWorkout.removeAll()
                do {
                    let workouts = try await self.useCase.fetchWorkoutData()
                    if workouts.isEmpty {
                        self.viewStatus = .empty
                    } else {
                        self.classifyWorkoutsByDate(workouts: workouts)
                        self.viewStatus = .none
                    }
                } catch {
                    NavigationCoordinator.shared.push(.init(
                        title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                        message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                        firstButton: .cancel(title: "확인", action: {}),
                        secondButton: nil
                    ))
                }
            }
        }))
    }
    
    @MainActor
    public func cancelButtonTapped() {
        self.selectedWorkout.removeAll()
        self.viewStatus = workouts.isEmpty ? .empty : .none
    }
    
    public func isSelectedWorkout(_ workout: Workout) -> Bool {
        self.selectedWorkout.contains(workout.id)
    }
}


extension WorkoutListViewModel {
    private func classifyWorkoutsByDate(workouts: [Workout]) {
        self.workouts.removeAll()
        self.dateHeaders.removeAll()
        
        var resultWorkouts = [Workout]()
        
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

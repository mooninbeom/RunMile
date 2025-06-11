//
//  ShoesDetailViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation


@Observable
final class ShoesDetailViewModel {
    private let useCase: ShoesDetailUseCase
    
    public var shoes: Shoes
    public var viewStatus: ViewStatus = .normal {
        didSet {
            goalMileage = "\(Int(shoes.goalMileage))"
        }
    }
    
    public var goalMileage: String = ""
    public var selectedWorkouts: Set<UUID> = []
    
    public var isHallOfFame: Bool {
        Double(self.shoes.getCurrentMileage)! >= self.shoes.goalMileage
    }
    
    init(useCase: ShoesDetailUseCase, shoes: Shoes) {
        self.useCase = useCase
        self.shoes = shoes
    }
    
    enum ViewStatus: Equatable {
        case normal
        case editing
        case workouts
    }
}


extension ShoesDetailViewModel {
    @MainActor
    public func editButtonTapped() {
        self.viewStatus = .editing
    }
    
    @MainActor
    public func cancelButtonTapped() {
        selectedWorkouts.removeAll()
        self.viewStatus = .normal
    }
    
    @MainActor
    public func choiceButtonTapped() {
        self.viewStatus = .workouts
    }
    
    @MainActor
    public func deleteButtonTapped() {
        let alert = AlertData(
            title: "정말 삭제하시겠습니까?",
            message: "삭제된 데이터는 되돌릴 수 없습니다.",
            firstButton: .cancel(title: "취소") {},
            secondButton: .ok(title: "삭제") {
                self.deleteShoes()
            }
        )
        
        NavigationCoordinator.shared.push(alert)
    }
    
    @MainActor
    public func completeButtonTapped() {
        let modified = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: Double(goalMileage)!,
            currentMileage: shoes.currentMileage,
            workouts: shoes.workouts
        )
        
        Task {
            do {
                try await useCase.editShoes(shoes: modified)
                self.shoes = modified
                self.viewStatus = .normal
            } catch {
                NavigationCoordinator.shared.push(.init(
                    title: "저장 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
    
    @MainActor
    public func workoutCellTapped(_ workout: RunningData) {
        switch self.viewStatus {
        case .workouts:
            if selectedWorkouts.contains(workout.id) {
                selectedWorkouts.remove(workout.id)
            } else {
                selectedWorkouts.insert(workout.id)
            }
        default: break
        }
    }
    
    @MainActor
    public func deleteWorkoutsButtonTapped() {
        let alert = AlertData(
            title: "\(self.selectedWorkouts.count)개의 운동을 제거하시겠습니까?",
            message: "제거된 운동은 추후에 다시 등록이 가능합니다!",
            firstButton: .cancel(title: "취소", action: {}),
            secondButton: .ok(title: "확인", action: self.deleteWorkouts)
        )
        
        NavigationCoordinator.shared.push(alert)
    }
    
    @MainActor
    public func HOFButtonTapped() {
        let alert = AlertData(
            title: "정말로 진행하시겠습니까?",
            message: "명예의 전당으로 간 신발은 더 이상 마일리지를 추가할 수 없습니다.",
            firstButton: .cancel(title: "취소", action: {}),
            secondButton: .ok(title: "확인", action: editShoesHOF)
        )
        
        NavigationCoordinator.shared.push(alert)
    }
    
    @MainActor
    public func imageTapped() {
        NavigationCoordinator.shared.push(.imageDetail(shoes.image), tab: .shoes)
    }
}


// MARK: - Internal Function
extension ShoesDetailViewModel {
    private func deleteShoes() {
        Task {
            do {
                try await useCase.deleteShoes(shoes: self.shoes)
                let alert = AlertData(
                    title: "삭제를 완료했습니다.",
                    message: nil,
                    firstButton: .cancel(title: "확인") {
                        Task {
                            await NavigationCoordinator.shared.pop(.shoes)
                        }
                    },
                    secondButton: nil
                )
                
                await NavigationCoordinator.shared.push(alert)
                
            } catch {
                let alert = AlertData(
                    title: "삭제 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                )
                
                await NavigationCoordinator.shared.push(alert)
            }
        }
    }
    
    private func deleteWorkouts() {
        let workout = shoes.workouts.filter { !selectedWorkouts.contains($0.id) }
        
        let modified = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: shoes.goalMileage,
            currentMileage: shoes.currentMileage,
            workouts: workout
        )
        
        Task {
            do {
                try await useCase.editShoes(shoes: modified)
                self.shoes.workouts = workout
                self.selectedWorkouts.removeAll()
                self.viewStatus = .normal
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "저장 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
    
    private func editShoesHOF() {
        let modified = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: shoes.goalMileage,
            currentMileage: shoes.currentMileage,
            workouts: shoes.workouts,
            isGraduate: true
        )
        
        Task {
            do {
                try await self.useCase.graduateShoes(shoes: modified)
                await NavigationCoordinator.shared.pop(.shoes)
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "저장 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
}

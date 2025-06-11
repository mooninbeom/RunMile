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
    public func shoesCellTapped(shoes: Shoes) {
        Task {
            do {
                try await useCase.registerWorkouts(shoes: shoes, workouts: workouts)
                cancelButtonTapped()
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
}

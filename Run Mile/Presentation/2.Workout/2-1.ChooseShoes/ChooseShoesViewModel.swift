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
    private let workouts: [Workout]
    private let dismissAction: () -> Void
    private var isPresentingMoveRegisteredWorkoutsAlert = false
    private var didHandleSheetDismiss = false

    public var shoes: [Shoes] = []
    public var selectedShoe: Shoes? = nil

    public var workoutCount: Int { workouts.count }

    init(
        useCase: ChooseShoesUseCase,
        workouts: [Workout],
        dismissAction: @escaping () -> Void = {}
    ) {
        self.useCase = useCase
        self.workouts = workouts
        self.dismissAction = dismissAction
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
        handleSheetDismiss()
    }

    @MainActor
    public func sheetDidDisappear() {
        guard !isPresentingMoveRegisteredWorkoutsAlert else {
            return
        }
        handleSheetDismiss()
    }

    @MainActor
    public func shoesCellTapped(shoe: Shoes) {
        if self.selectedShoe?.id == shoe.id {
            self.selectedShoe = nil
        } else {
            self.selectedShoe = shoe
        }
    }

    @MainActor
    public func saveButtonTapped() {
        guard let selectedShoe = self.selectedShoe else {
            return
        }

        Task {
            do {
                let conflictCount = try await useCase.registeredWorkoutConflictCount(
                    targetShoes: selectedShoe,
                    workouts: workouts
                )

                if conflictCount > 0 {
                    presentMoveRegisteredWorkoutsAlert(
                        selectedShoe: selectedShoe,
                        conflictCount: conflictCount
                    )
                } else {
                    try await registerWorkouts(
                        to: selectedShoe,
                        shouldMoveRegisteredWorkouts: false
                    )
                }
            } catch {
                presentSaveFailureAlert(error: error)
            }
        }
    }

    @MainActor
    private func presentMoveRegisteredWorkoutsAlert(selectedShoe: Shoes, conflictCount: Int) {
        isPresentingMoveRegisteredWorkoutsAlert = true
        NavigationCoordinator.shared.push(.init(
            title: "이미 등록된 운동이 포함되어 있습니다.",
            message: "선택한 운동 중 \(conflictCount)개가 이미 다른 신발에 등록되어 있습니다.\n해당 운동을 \(selectedShoe.nickname)로 옮길까요?",
            firstButton: .cancel(title: "취소", action: { [self] in
                Task {
                    await MainActor.run {
                        self.isPresentingMoveRegisteredWorkoutsAlert = false
                    }
                }
            }),
            secondButton: .ok(title: "옮기기", action: { [self] in
                Task {
                    await self.moveRegisteredWorkouts(to: selectedShoe)
                }
            })
        ))
    }

    @MainActor
    private func moveRegisteredWorkouts(to selectedShoe: Shoes) async {
        isPresentingMoveRegisteredWorkoutsAlert = false
        do {
            try await registerWorkouts(
                to: selectedShoe,
                shouldMoveRegisteredWorkouts: true
            )
        } catch {
            presentSaveFailureAlert(error: error)
        }
    }

    @MainActor
    private func registerWorkouts(
        to selectedShoe: Shoes,
        shouldMoveRegisteredWorkouts: Bool
    ) async throws {
        try await useCase.registerWorkouts(
            shoes: selectedShoe,
            workouts: workouts,
            shouldMoveRegisteredWorkouts: shouldMoveRegisteredWorkouts
        )
        cancelButtonTapped()
    }

    @MainActor
    private func presentSaveFailureAlert(error: Error) {
        NavigationCoordinator.shared.push(.init(
            title: "저장 과정 중 오류가 발생했습니다.",
            message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
            firstButton: .cancel(title: "확인", action: {}),
            secondButton: nil
        ))
    }

    @MainActor
    private func handleSheetDismiss() {
        guard !didHandleSheetDismiss else {
            return
        }

        didHandleSheetDismiss = true
        dismissAction()
    }
}

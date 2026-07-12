//
//  ScreenFactory.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ScreenFactory {
    private let container: ScreenDependencyProviding
    
    init(container: ScreenDependencyProviding) {
        self.container = container
    }
    
    /// NavigationCoordinator의 화면 상태를 실제 SwiftUI 화면으로 변환합니다.
    @MainActor
    @ViewBuilder
    func makeView(for screen: NavigationCoordinator.Screen) -> some View {
        switch screen {
        case .shoes:
            ShoesListView(viewModel: container.makeShoesListViewModel())
        case let .shoesDetail(shoes):
            ShoesDetailView(viewModel: container.makeShoesDetailViewModel(shoes: shoes))
            
        case .workout:
            WorkoutListView(viewModel: container.makeWorkoutListViewModel())
        case let .workoutDetail(workout):
            WorkoutDetailView(viewModel: container.makeWorkoutDetailViewModel(workout: workout))
            
        case .myPage:
            MyPageView(viewModel: container.makeMyPageViewModel())
        case .fitnessConnect:
            FitnessConnectView()
        case .hof:
            HOFView(viewModel: container.makeHOFViewModel())
        case let .hofReport(shoes):
            HOFReportView(viewModel: container.makeHOFReportViewModel(shoes: shoes))
        case .info:
            InformationView(viewModel: container.makeInformationViewModel())
        case let .imageDetail(image):
            if #available(iOS 18.0, *) {
                ImageDetailView(image: image)
                    .toolbarVisibility(.hidden, for: .tabBar)
            } else {
                ImageDetailView(image: image)
                    .toolbar(.hidden, for: .tabBar)
            }
        }
    }
    
    /// NavigationCoordinator의 Sheet 상태를 실제 SwiftUI sheet 화면으로 변환합니다.
    @MainActor
    @ViewBuilder
    func makeSheet(for sheet: NavigationCoordinator.Sheet) -> some View {
        switch sheet {
        case let .addShoes(action):
            AddShoesView(
                viewModel: container.makeAddShoesViewModel(),
                dismissAction: {
                    action()
                    Task { @MainActor in
                        NavigationCoordinator.shared.presentPendingCustomSheetIfNeeded()
                    }
                }
            )
        case let .chooseShoes(workouts, action):
            ChooseShoesView(
                viewModel: container.makeChooseShoesViewModel(
                    workouts: workouts,
                    dismissAction: action
                )
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
        case .automaticRegister:
            AutoMileageShoesView(viewModel: container.makeAutoMileageShoesViewModel())
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
    }

    /// NavigationCoordinator의 커스텀 Sheet 상태를 앱 루트 overlay 화면으로 변환합니다.
    @MainActor
    @ViewBuilder
    func makeCustomSheet(for sheet: NavigationCoordinator.CustomSheet) -> some View {
        switch sheet {
        case .addShoesNotificationPermission:
            AddShoesNotificationPermissionSheetContainer(
                viewModel: container.makeAddShoesNotificationPermissionSheetViewModel()
            )
        }
    }
}

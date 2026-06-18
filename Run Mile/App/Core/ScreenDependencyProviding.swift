//
//  ScreenDependencyProviding.swift
//  Run Mile
//
//  Created by 테스트 on 5/8/26.
//

import Foundation


protocol ScreenDependencyProviding {
    func makeOnboardingViewModel() -> OnboardingViewModel
    func makeShoesListViewModel() -> ShoesListViewModel
    func makeShoesDetailViewModel(shoes: Shoes) -> ShoesDetailViewModel
    func makeAddShoesViewModel() -> AddShoesViewModel
    func makeAddShoesNotificationPermissionSheetViewModel() -> AddShoesNotificationPermissionSheetViewModel
    func makeWorkoutListViewModel() -> WorkoutListViewModel
    func makeWorkoutDetailViewModel(workout: Workout) -> WorkoutDetailViewModel
    func makeChooseShoesViewModel(workouts: [Workout], dismissAction: @escaping () -> Void) -> ChooseShoesViewModel
    func makeAutoMileageShoesViewModel() -> AutoMileageShoesViewModel
    func makeMyPageViewModel() -> MyPageViewModel
    func makeHOFViewModel() -> HOFViewModel
    func makeHOFReportViewModel(shoes: Shoes) -> HOFReportViewModel
    func makeInformationViewModel() -> InformationViewModel
}

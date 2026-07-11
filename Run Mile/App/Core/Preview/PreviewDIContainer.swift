//
//  PreviewDIContainer.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import Foundation


final class PreviewDIContainer: ScreenDependencyProviding {
    /// 온보딩 Preview용 ViewModel을 HealthKit 권한 요청 없이 생성합니다.
    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            useCase: PreviewHealthDataUseCase(),
            healthKitSampleSeeder: PreviewHealthKitSampleSeeder()
        )
    }

    /// 신발 목록 Preview용 ViewModel을 샘플 데이터가 주입된 상태로 생성합니다.
    func makeShoesListViewModel() -> ShoesListViewModel {
        let viewModel = ShoesListViewModel(
            useCase: PreviewShoesListUseCase(
                shoes: PreviewShoesMockData.shoes,
                monthlyDistance: PreviewShoesMockData.monthlyRunningDistance
            )
        )
        viewModel.shoes = PreviewShoesMockData.shoes
        viewModel.monthlyDistanceText = String(
            format: "%.1f km",
            PreviewShoesMockData.monthlyRunningDistance
        )
        return viewModel
    }
    
    /// 신발 상세 Preview용 ViewModel을 샘플 액션 UseCase와 함께 생성합니다.
    @MainActor
    func makeShoesDetailViewModel(shoes: Shoes) -> ShoesDetailViewModel {
        ShoesDetailViewModel(
            useCase: PreviewShoesDetailUseCase(),
            shoes: shoes
        )
    }
    
    /// 신발 추가 Preview용 ViewModel을 기본 입력값이 채워진 상태로 생성합니다.
    @MainActor
    func makeAddShoesViewModel() -> AddShoesViewModel {
        let viewModel = AddShoesViewModel(useCase: PreviewAddShoesUseCase())
        viewModel.selectedBrand = "Nike"
        viewModel.selectedModel = "Pegasus 41"
        viewModel.usage = "데일리 러닝"
        viewModel.goalMileage = "700"
        return viewModel
    }

    /// 첫 신발 등록 이후 알림 권한 안내 커스텀 시트 Preview용 ViewModel을 생성합니다.
    func makeAddShoesNotificationPermissionSheetViewModel() -> AddShoesNotificationPermissionSheetViewModel {
        AddShoesNotificationPermissionSheetViewModel(
            useCase: PreviewNotificationPermissionUseCase()
        )
    }
    
    /// 운동 목록 Preview용 ViewModel을 샘플 운동 기록이 채워진 상태로 생성합니다.
    func makeWorkoutListViewModel() -> WorkoutListViewModel {
        let viewModel = WorkoutListViewModel(
            useCase: PreviewHealthDataUseCase(),
            healthBackgroundSyncService: PreviewHealthBackgroundSyncService()
        )
        let currentMonthWorkouts = Array(PreviewShoesMockData.workouts.prefix(3))
        let previousMonthWorkouts = Array(PreviewShoesMockData.workouts.suffix(2))
        viewModel.dateHeaders = [
            currentMonthWorkouts.first?.date.yearMonth ?? "2026년 5월",
            previousMonthWorkouts.first?.date.yearMonth ?? "2026년 4월"
        ]
        viewModel.workouts = [currentMonthWorkouts, previousMonthWorkouts]
        viewModel.workoutShoeRegistrationInfo = PreviewWorkoutMockData.workoutShoeRegistrationInfo
        viewModel.viewStatus = .selection
        return viewModel
    }
    
    /// 운동 상세 Preview용 ViewModel을 샘플 상세 데이터 UseCase와 함께 생성합니다.
    func makeWorkoutDetailViewModel(workout: Workout) -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(
            useCase: PreviewWorkoutDetailUseCase(),
            workout: workout
        )
    }
    
    /// 신발 선택 Sheet Preview용 ViewModel을 샘플 신발 목록이 채워진 상태로 생성합니다.
    func makeChooseShoesViewModel(
        workouts: [Workout],
        dismissAction: @escaping () -> Void = {}
    ) -> ChooseShoesViewModel {
        let viewModel = ChooseShoesViewModel(
            useCase: PreviewChooseShoesUseCase(),
            workouts: workouts,
            dismissAction: dismissAction
        )
        viewModel.shoes = PreviewShoesMockData.shoes
        viewModel.selectedShoe = PreviewShoesMockData.shoes.first
        return viewModel
    }
    
    /// 자동 마일리지 등록 Preview용 ViewModel을 샘플 신발 목록이 채워진 상태로 생성합니다.
    func makeAutoMileageShoesViewModel() -> AutoMileageShoesViewModel {
        let viewModel = AutoMileageShoesViewModel(useCase: PreviewAddMileageShoesUseCase())
        viewModel.shoes = PreviewShoesMockData.shoes
        viewModel.selectedShoesId = PreviewShoesMockData.shoes.first?.id
        return viewModel
    }
    
    /// 마이페이지 Preview용 ViewModel을 생성합니다.
    func makeMyPageViewModel() -> MyPageViewModel {
        MyPageViewModel(useCase: PreviewMyPageUseCase())
    }
    
    /// 명예의 전당 Preview용 ViewModel을 졸업 신발 샘플 데이터가 채워진 상태로 생성합니다.
    func makeHOFViewModel() -> HOFViewModel {
        let viewModel = HOFViewModel(useCase: PreviewHOFUseCase())
        viewModel.shoes = PreviewShoesMockData.hallOfFameShoes
        return viewModel
    }
    
    /// 졸업 리포트 Preview용 ViewModel을 샘플 신발 데이터로 생성합니다.
    func makeHOFReportViewModel(shoes: Shoes) -> HOFReportViewModel {
        HOFReportViewModel(shoes: shoes, useCase: PreviewHOFUseCase())
    }
    
    /// 개발자 정보 Preview용 ViewModel을 생성합니다.
    func makeInformationViewModel() -> InformationViewModel {
        InformationViewModel()
    }
}

private final class PreviewHealthBackgroundSyncService: HealthBackgroundSyncService {
    func enableBackgroundDelivery() async {}
    func registerHealthBackgroundQueryTask() {}
    func processPendingRunningWorkoutsIfNeeded() async {}
    func fetchRunningWorkout(id: UUID) async throws -> Workout? { nil }
}
#endif

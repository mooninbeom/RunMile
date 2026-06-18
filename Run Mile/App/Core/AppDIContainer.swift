//
//  AppDIContainer.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import Foundation


final class AppDIContainer: ScreenDependencyProviding {
    static let shared = AppDIContainer()
    
    private let workoutRepository: WorkoutDataRepository
    private let shoesRepository: ShoesDataRepository
    private let distanceRecordCacheRepository: WorkoutDistanceRecordCacheRepository
    private let healthBackgroundSyncService: HealthBackgroundSyncService
    private let notificationPermissionService: NotificationPermissionService
    private let healthKitSampleSeeder: HealthKitSampleSeeding
    
    init(
        workoutRepository: WorkoutDataRepository = WorkoutDataRepositoryImpl(),
        shoesRepository: ShoesDataRepository = ShoesDataRepositoryImpl(),
        distanceRecordCacheRepository: WorkoutDistanceRecordCacheRepository = WorkoutDistanceRecordCacheRepositoryImpl(),
        healthBackgroundSyncService: HealthBackgroundSyncService? = nil,
        notificationPermissionService: NotificationPermissionService = UserNotificationPermissionService(),
        healthKitSampleSeeder: HealthKitSampleSeeding = HealthKitSampleSeeder()
    ) {
        self.workoutRepository = workoutRepository
        self.shoesRepository = shoesRepository
        self.distanceRecordCacheRepository = distanceRecordCacheRepository
        self.notificationPermissionService = notificationPermissionService
        self.healthKitSampleSeeder = healthKitSampleSeeder
        self.healthBackgroundSyncService = healthBackgroundSyncService
        ?? DefaultHealthBackgroundSyncService(shoesRepository: shoesRepository)
    }
    
    /// HealthKit 백그라운드 운동 감지와 신발 자동 등록을 담당하는 서비스를 제공합니다.
    func makeHealthBackgroundSyncService() -> HealthBackgroundSyncService {
        healthBackgroundSyncService
    }

    /// 온보딩 화면의 상태와 건강 데이터 권한 요청 액션을 관리하는 ViewModel을 생성합니다.
    func makeOnboardingViewModel() -> OnboardingViewModel {
        OnboardingViewModel(
            useCase: DefaultHealthDataUseCase(
                workoutDataRepository: workoutRepository,
                shoesDataRepository: shoesRepository
            ),
            healthKitSampleSeeder: healthKitSampleSeeder
        )
    }
    
    /// 신발 목록 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeShoesListViewModel() -> ShoesListViewModel {
        ShoesListViewModel(
            useCase: DefaultShoesViewUseCase(
                repository: shoesRepository,
                workoutRepository: workoutRepository
            )
        )
    }
    
    /// 신발 상세 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeShoesDetailViewModel(shoes: Shoes) -> ShoesDetailViewModel {
        ShoesDetailViewModel(
            useCase: DefaultShoesDetailUseCase(
                repository: shoesRepository
            ),
            shoes: shoes
        )
    }
    
    /// 신발 추가 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeAddShoesViewModel() -> AddShoesViewModel {
        AddShoesViewModel(
            useCase: DefaultAddShoesUseCase(
                repository: shoesRepository,
                notificationPermissionService: notificationPermissionService
            )
        )
    }

    /// 첫 신발 등록 이후 알림 권한 안내 커스텀 시트의 ViewModel을 생성합니다.
    func makeAddShoesNotificationPermissionSheetViewModel() -> AddShoesNotificationPermissionSheetViewModel {
        AddShoesNotificationPermissionSheetViewModel(
            useCase: DefaultNotificationPermissionUseCase(
                notificationPermissionService: notificationPermissionService
            )
        )
    }
    
    /// 운동 목록 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeWorkoutListViewModel() -> WorkoutListViewModel {
        WorkoutListViewModel(
            useCase: DefaultHealthDataUseCase(
                workoutDataRepository: workoutRepository,
                shoesDataRepository: shoesRepository
            ),
            healthBackgroundSyncService: healthBackgroundSyncService
        )
    }
    
    /// 운동 상세 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeWorkoutDetailViewModel(workout: Workout) -> WorkoutDetailViewModel {
        WorkoutDetailViewModel(
            useCase: DefaultWorkoutDetailUseCase(
                workoutRepository: workoutRepository
            ),
            workout: workout
        )
    }
    
    /// 운동 기록을 신발에 연결하는 화면의 ViewModel을 생성합니다.
    func makeChooseShoesViewModel(
        workouts: [Workout],
        dismissAction: @escaping () -> Void
    ) -> ChooseShoesViewModel {
        ChooseShoesViewModel(
            useCase: DefaultChooseShoesUseCase(
                repository: shoesRepository
            ),
            workouts: workouts,
            dismissAction: dismissAction
        )
    }
    
    /// 자동 마일리지 등록 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeAutoMileageShoesViewModel() -> AutoMileageShoesViewModel {
        AutoMileageShoesViewModel(
            useCase: DefaultAddMileageShoesUseCase(
                shoesRepository: shoesRepository
            )
        )
    }
    
    /// 마이페이지 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeMyPageViewModel() -> MyPageViewModel {
        MyPageViewModel(
            useCase: DefaultMyPageUseCase()
        )
    }
    
    /// 명예의 전당 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeHOFViewModel() -> HOFViewModel {
        HOFViewModel(
            useCase: DefaultHOFUseCase(
                repository: shoesRepository,
                workoutRepository: workoutRepository,
                distanceRecordCacheRepository: distanceRecordCacheRepository
            )
        )
    }
    
    /// 졸업 신발의 리포트 표시 데이터를 관리하는 ViewModel을 생성합니다.
    func makeHOFReportViewModel(shoes: Shoes) -> HOFReportViewModel {
        HOFReportViewModel(
            shoes: shoes,
            useCase: DefaultHOFUseCase(
                repository: shoesRepository,
                workoutRepository: workoutRepository,
                distanceRecordCacheRepository: distanceRecordCacheRepository
            )
        )
    }
    
    /// 개발자 정보 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeInformationViewModel() -> InformationViewModel {
        InformationViewModel()
    }
}

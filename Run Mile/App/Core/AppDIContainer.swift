//
//  AppDIContainer.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import Foundation


final class AppDIContainer: ScreenDependencyProviding {
    private let workoutRepository: WorkoutDataRepository
    private let shoesRepository: ShoesDataRepository
    
    init(
        workoutRepository: WorkoutDataRepository = WorkoutDataRepositoryImpl(),
        shoesRepository: ShoesDataRepository = ShoesDataRepositoryImpl()
    ) {
        self.workoutRepository = workoutRepository
        self.shoesRepository = shoesRepository
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
                repository: shoesRepository
            )
        )
    }
    
    /// 운동 목록 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeWorkoutListViewModel() -> WorkoutListViewModel {
        WorkoutListViewModel(
            useCase: DefaultHealthDataUseCase(
                workoutDataRepository: workoutRepository,
                shoesDataRepository: shoesRepository
            )
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
    func makeChooseShoesViewModel(workouts: [Workout]) -> ChooseShoesViewModel {
        ChooseShoesViewModel(
            useCase: DefaultChooseShoesUseCase(
                repository: shoesRepository
            ),
            workouts: workouts
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
                repository: shoesRepository
            )
        )
    }
    
    /// 개발자 정보 화면의 상태와 액션을 관리하는 ViewModel을 생성합니다.
    func makeInformationViewModel() -> InformationViewModel {
        InformationViewModel()
    }
}


//
//  HealthDataUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit


protocol HealthDataUseCase {
    /// Health 데이터 사용 권한 요청이 이루어졌는지 확인하고 요청을 보냅니다.
    @discardableResult
    func checkHealthAuthorization() async throws -> Bool
    
    func fetchWorkoutData() async throws -> [Workout]

    func fetchWorkoutShoeRegistrationInfo() async throws -> [UUID: WorkoutShoeRegistrationInfo]
}



final class DefaultHealthDataUseCase: HealthDataUseCase {
    private let store = HKHealthStore()
    private let workoutDataRepository: WorkoutDataRepository
    private let shoesDataRepository: ShoesDataRepository
    
    init(
        workoutDataRepository: WorkoutDataRepository,
        shoesDataRepository: ShoesDataRepository
    ) {
        self.workoutDataRepository = workoutDataRepository
        self.shoesDataRepository = shoesDataRepository
    }
    
    public func checkHealthAuthorization() async throws -> Bool {
        let isNeedRequested = try await checkAuthorizationStatus()
        
        if !isNeedRequested {
            return false
        }
        
        try await requestAuthorization()
        return true
    }
    
    public func fetchWorkoutData() async throws -> [Workout] {
        try await workoutDataRepository.fetchAllWorkoutData()
    }

    public func fetchWorkoutShoeRegistrationInfo() async throws -> [UUID: WorkoutShoeRegistrationInfo] {
        let shoes = try await shoesDataRepository.fetchAllShoes()
        var result: [UUID: WorkoutShoeRegistrationInfo] = [:]

        for shoe in shoes {
            for workout in shoe.workouts {
                result[workout.id] = WorkoutShoeRegistrationInfo(
                    shoeName: shoe.shoesName,
                    isGraduated: shoe.isGradutate
                )
            }
        }

        return result
    }
}


// MARK: - Internal Method
extension DefaultHealthDataUseCase {
    /// Health 데이터 사용 권한 요청이 이루어졌는지 확인합니다.
    private func checkAuthorizationStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            store.getRequestStatusForAuthorization(
                toShare: healthShareTypes,
                read: healthReadTypes
            ) { status, error in
                if error != nil {
                    continuation.resume(throwing: HealthError.unknownError)
                    return
                }
                
                switch status {
                case .shouldRequest:
                    continuation.resume(returning: true)
                default:
                    continuation.resume(returning: false)
                }
            }
        }
    }
    
    /// Health 데이터 사용 권한을 요청합니다.
    private func requestAuthorization() async throws {
        if HKHealthStore.isHealthDataAvailable() {
            try await store.requestAuthorization(
                toShare: healthShareTypes,
                read: healthReadTypes
            )
        } else {
            throw HealthError.notAvailableDevice
        }
    }
    
    /// 앱에서 읽어오는 HealthKit 데이터 타입을 한 곳에서 관리합니다.
    private var healthReadTypes: Set<HKObjectType> {
        [
            HKSeriesType.workoutRoute(),
            .workoutType(),
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!,
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .runningPower)!,
            .quantityType(forIdentifier: .runningSpeed)!,
            .quantityType(forIdentifier: .runningStrideLength)!,
            .quantityType(forIdentifier: .runningVerticalOscillation)!,
            .quantityType(forIdentifier: .runningGroundContactTime)!
        ]
    }
    
    /// Simulator 디버깅에서 샘플 운동을 생성할 때 필요한 쓰기 권한 타입을 관리합니다.
    private var healthShareTypes: Set<HKSampleType> {
        #if DEBUG && targetEnvironment(simulator)
        return [
            HKSeriesType.workoutRoute(),
            .workoutType(),
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!,
            .quantityType(forIdentifier: .stepCount)!,
            .quantityType(forIdentifier: .runningPower)!,
            .quantityType(forIdentifier: .runningSpeed)!,
            .quantityType(forIdentifier: .runningStrideLength)!,
            .quantityType(forIdentifier: .runningVerticalOscillation)!,
            .quantityType(forIdentifier: .runningGroundContactTime)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!
        ]
        #else
        return []
        #endif
    }
}

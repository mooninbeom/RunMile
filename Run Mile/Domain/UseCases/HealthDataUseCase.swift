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
        try await workoutDataRepository.fetchUnsavedWorkoutData()
    }
}


// MARK: - Internal Method
extension DefaultHealthDataUseCase {
    /// Health 데이터 사용 권한 요청이 이루어졌는지 확인합니다.
    private func checkAuthorizationStatus() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            store.getRequestStatusForAuthorization(
                toShare: Set(),
                read: Set([.workoutType()])
            ) { status, error in
                if let _ = error {
                    continuation.resume(throwing: HealthError.unknownError)
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
                toShare: Set(),
                read: Set([.workoutType()])
            )
        } else {
            throw HealthError.notAvailableDevice
        }
    }
}

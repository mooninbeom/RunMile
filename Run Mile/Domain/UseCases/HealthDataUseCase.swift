//
//  HealthDataUseCase.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit


protocol HealthDataUseCase {
    func checkHealthAuthorization() async throws -> Bool
}



final class DefaultHealthDataUseCase: HealthDataUseCase {
    let store = HKHealthStore()
    
    public func checkHealthAuthorization() async throws -> Bool {
        let isNeedRequested = try await checkAuthorizationStatus()
        
        if !isNeedRequested {
            return false
        }
        
        try await requestAuthorization()
        return true
    }
    
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
    
    private func requestAuthorization() async throws {
        if HKHealthStore.isHealthDataAvailable() {
            try await store.requestAuthorization(toShare: Set(), read: Set([.workoutType()]))
        } else {
            throw HealthError.notAvailableDevice
        }
    }
}


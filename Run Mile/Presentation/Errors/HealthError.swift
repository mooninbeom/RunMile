//
//  HealthError.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation


/**
 HealthKit 관련 Error
 */
enum HealthError: Error {
    case unknownError
    case notAvailableDevice
    case failedToLoadWorkoutData
}


extension HealthError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .unknownError:
            NSLocalizedString("알 수 없는 오류 발생", comment: "Unknown error")
        case .notAvailableDevice:
            NSLocalizedString("지원하지 않는 기기", comment: "Not available device")
        case .failedToLoadWorkoutData:
            NSLocalizedString("운동 데이터 불러오기 실패", comment: "Failed to load workout data")
        }
    }
}

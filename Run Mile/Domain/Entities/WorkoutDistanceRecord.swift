//
//  WorkoutDistanceRecord.swift
//  Run Mile
//
//  Created by Codex on 5/17/26.
//

import Foundation


enum WorkoutDistanceRecordTarget: String, CaseIterable, Codable, Identifiable, Sendable, Hashable {
    case fiveK
    case tenK
    case halfMarathon
    case marathon
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .fiveK:
            return "5K"
        case .tenK:
            return "10K"
        case .halfMarathon:
            return "Half"
        case .marathon:
            return "Full"
        }
    }
    
    var meters: Double {
        switch self {
        case .fiveK:
            return 5_000
        case .tenK:
            return 10_000
        case .halfMarathon:
            return 21_097.5
        case .marathon:
            return 42_195
        }
    }
    
    var unavailableText: String {
        switch self {
        case .fiveK:
            return "5km 이상 러닝 없음"
        case .tenK:
            return "10km 이상 러닝 없음"
        case .halfMarathon:
            return "하프 이상 러닝 없음"
        case .marathon:
            return "풀코스 기록 없음"
        }
    }
}


struct WorkoutDistanceRecord: Codable, Identifiable, Sendable, Hashable {
    let workoutID: UUID
    let target: WorkoutDistanceRecordTarget
    let duration: TimeInterval
    let workoutDate: Date
    let segmentStartDate: Date
    let segmentEndDate: Date
    let sourceWorkoutDistance: Double
    
    var id: String {
        "\(workoutID.uuidString)-\(target.rawValue)"
    }
}


struct WorkoutDistanceSample: Sendable {
    let startDate: Date
    let endDate: Date
    let distance: Double
}

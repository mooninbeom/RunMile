//
//  WorkoutDistanceRecordCacheRepository.swift
//  Run Mile
//
//  Created by Codex on 5/17/26.
//

import Foundation


protocol WorkoutDistanceRecordCacheRepository: Sendable {
    func fetchRecords(for workout: Workout) async -> [WorkoutDistanceRecord]?
    func saveRecords(_ records: [WorkoutDistanceRecord], for workout: Workout) async
}

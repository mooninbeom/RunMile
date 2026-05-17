//
//  WorkoutDistanceRecordCacheRepositoryImpl.swift
//  Run Mile
//
//  Created by Codex on 5/17/26.
//

import Foundation


actor WorkoutDistanceRecordCacheRepositoryImpl: WorkoutDistanceRecordCacheRepository {
    private let cacheKey = "hofWorkoutDistanceRecordCache.v2"
    private let maxCacheCount = 1_000
    
    /// 운동 ID와 운동 메타데이터가 일치하는 캐시만 반환합니다.
    func fetchRecords(for workout: Workout) async -> [WorkoutDistanceRecord]? {
        let store = loadStore()
        guard let entry = store[workout.id.uuidString],
              entry.matches(workout: workout) else {
            return nil
        }
        
        return entry.records
    }
    
    /// 거리별 PB 계산 결과를 운동 ID 기준으로 저장해 추후 PB 카드와 운동 상세 연결에 사용합니다.
    func saveRecords(_ records: [WorkoutDistanceRecord], for workout: Workout) async {
        var store = loadStore()
        store[workout.id.uuidString] = CachedWorkoutDistanceRecordEntry(
            workoutID: workout.id,
            workoutStartDate: workout.workout.startDate,
            workoutEndDate: workout.workout.endDate,
            workoutDuration: workout.time,
            workoutDistance: workout.distance,
            cachedAt: Date(),
            records: records
        )
        
        if store.count > maxCacheCount {
            store = Dictionary(
                uniqueKeysWithValues: store
                    .sorted { $0.value.cachedAt > $1.value.cachedAt }
                    .prefix(maxCacheCount)
                    .map { ($0.key, $0.value) }
            )
        }
        
        saveStore(store)
    }
    
    private func loadStore() -> [String: CachedWorkoutDistanceRecordEntry] {
        guard let data = UserDefaults.standard.data(forKey: cacheKey) else {
            return [:]
        }
        
        return (try? JSONDecoder().decode([String: CachedWorkoutDistanceRecordEntry].self, from: data)) ?? [:]
    }
    
    private func saveStore(_ store: [String: CachedWorkoutDistanceRecordEntry]) {
        guard let data = try? JSONEncoder().encode(store) else {
            return
        }
        
        UserDefaults.standard.set(data, forKey: cacheKey)
    }
}


private struct CachedWorkoutDistanceRecordEntry: Codable {
    let workoutID: UUID
    let workoutStartDate: Date
    let workoutEndDate: Date
    let workoutDuration: TimeInterval
    let workoutDistance: Double
    let cachedAt: Date
    let records: [WorkoutDistanceRecord]
    
    func matches(workout: Workout) -> Bool {
        workoutID == workout.id
        && abs(workoutStartDate.timeIntervalSince(workout.workout.startDate)) < 1
        && abs(workoutEndDate.timeIntervalSince(workout.workout.endDate)) < 1
        && abs(workoutDuration - workout.time) < 1
        && abs(workoutDistance - workout.distance) < 1
    }
}

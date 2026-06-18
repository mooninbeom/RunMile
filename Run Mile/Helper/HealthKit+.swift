//
//  HealthKit+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import HealthKit


extension HKHealthStore {
    public func fetchData<T: HKSample>(
        sampleType: HKSampleType,
        predicate: NSPredicate,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) async throws -> [T] {
        let defaultSortDescriptor = [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]
        let data = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], any Error>) in
            let query = HKSampleQuery(
                sampleType: sampleType,
                predicate: predicate,
                limit: limit,
                sortDescriptors: sortDescriptors ?? defaultSortDescriptor) { query, samples, error in
                    if let _ = error {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                        return
                    }
                    
                    guard let samples = samples else {
                        continuation.resume(with: .failure(HealthError.failedToLoadWorkoutData))
                        return
                    }
                    
                    continuation.resume(with: .success(samples))
                }
            self.execute(query)
        }
        
        guard let result = data as? [T] else { throw HealthError.failedToLoadWorkoutData }
        
        return result
    }
    
    public func fetchSingleWorkoutData(id: UUID) async throws -> HKWorkout? {
        let sampleType = HKSampleType.workoutType()
        let predicate = HKSampleQuery.predicateForObject(with: id)
        
        let result: [HKWorkout] = try await fetchData(sampleType: sampleType, predicate: predicate, limit: 1)
        
        return result.first
    }
    
    public func fetchAvgCadence(workout: HKWorkout) async throws -> Double {
        let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount)!
        
        // 2. 워크아웃 시간 범위에 맞는 Predicate 생성
        let predicate = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate, options: .strictStartDate)
        
        // 3. 통계 쿼리 실행 (총 합계 구하기)
        let totalSteps = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
            let query = HKStatisticsQuery(quantityType: stepType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = result, let sum = result.sumQuantity() else {
                    // 걸음 수 데이터가 없으면 0 리턴
                    continuation.resume(returning: 0.0)
                    return
                }
                
                // 총 걸음 수 (Count 단위)
                let steps = sum.doubleValue(for: .count())
                continuation.resume(returning: steps)
            }
            self.execute(query)
        }
        
        // 4. 운동 시간(분) 계산
        // duration은 초(second) 단위이므로 60으로 나눔
        // 예외 처리: 운동 시간이 0이면 나눗셈 오류 방지
        let durationInMinutes = workout.duration / 60.0
        guard durationInMinutes > 0 else { return 0.0 }
        
        // 5. SPM 계산 및 반환
        return totalSteps / durationInMinutes
    }
}

extension HKWorkout {
    public func getKilometerDistance() -> Double? {
        if let statistics = self.statistics(for: HKQuantityType(.distanceWalkingRunning)),
           let sumDistance = statistics.sumQuantity() {
            return sumDistance.doubleValue(for: .meterUnit(with: .kilo))
        }
        return nil
    }
    
    public func getMeterDistance() -> Double {
        self.totalDistance?.doubleValue(for: .meter()) ?? 0.0
    }
    
    public func getAvgPace() -> String {
        (self.getMeterDistance() / self.duration).meterPerSecondToPace()
    }
    
    /// 운동에 기록된 active energy를 kcal 단위로 반환합니다.
    public func getActiveEnergyBurned() -> Double {
        if let statistics = self.statistics(for: HKQuantityType(.activeEnergyBurned)),
           let energy = statistics.sumQuantity() {
            return energy.doubleValue(for: .kilocalorie())
        }
        
        return self.totalEnergyBurned?.doubleValue(for: .kilocalorie()) ?? 0
    }
}

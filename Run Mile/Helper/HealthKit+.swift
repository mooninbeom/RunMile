//
//  HealthKit+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import HealthKit
import CoreLocation


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


// MARK: - Mock Data 메소드
enum HealthKitSampleMethod {
    static func createDetailedRunningWorkout() async throws -> HKWorkout {
        let store = HKHealthStore()
        
        // 1. 설정 구성
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor
        
        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        
        let startDate = Date().addingTimeInterval(-3600) // 1시간 전 시작
        let duration: TimeInterval = 1800 // 30분 운동
        let endDate = startDate.addingTimeInterval(duration)
        
        try await builder.beginCollection(at: startDate)
        
        // 2. 샘플 데이터 생성
        var samples: [HKSample] = []
        
        // 5초 간격으로 데이터 생성
        for i in 0..<Int(duration / 5) {
            let time = startDate.addingTimeInterval(Double(i) * 5)
            
            // 심박수 (140~160 사이 랜덤)
            let hrValue = Double.random(in: 140...160)
            let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            let hrSample = HKQuantitySample(type: hrType, quantity: HKQuantity(unit: .count().unitDivided(by: .minute()), doubleValue: hrValue), start: time, end: time)
            samples.append(hrSample)
            
            // 속도 (2.5 ~ 3.5 m/s)
            let speedValue = Double.random(in: 2.5...3.5)
            let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
            let speedSample = HKQuantitySample(type: speedType, quantity: HKQuantity(unit: .meter().unitDivided(by: .second()), doubleValue: speedValue), start: time, end: time)
            samples.append(speedSample)
            
            // 파워 (200 ~ 250 W)
            let powerValue = Double.random(in: 200...250)
            let powerType = HKQuantityType.quantityType(forIdentifier: .runningPower)!
            let powerSample = HKQuantitySample(type: powerType, quantity: HKQuantity(unit: .watt(), doubleValue: powerValue), start: time, end: time)
            samples.append(powerSample)
            
            // 수직 진폭 (6 ~ 10 cm)
            let oscValue = Double.random(in: 6...10)
            let oscType = HKQuantityType.quantityType(forIdentifier: .runningVerticalOscillation)!
            let oscSample = HKQuantitySample(type: oscType, quantity: HKQuantity(unit: .meterUnit(with: .centi), doubleValue: oscValue), start: time, end: time)
            samples.append(oscSample)
            
            // 지면 접촉 시간 (220 ~ 260 ms)
            let contactValue = Double.random(in: 220...260)
            let contactType = HKQuantityType.quantityType(forIdentifier: .runningGroundContactTime)!
            let contactSample = HKQuantitySample(type: contactType, quantity: HKQuantity(unit: .secondUnit(with: .milli), doubleValue: contactValue), start: time, end: time)
            samples.append(contactSample)
        }
        
        // 총 거리 (약 5km)
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let distanceSample = HKQuantitySample(type: distanceType, quantity: HKQuantity(unit: .meter(), doubleValue: 5000), start: startDate, end: endDate)
        samples.append(distanceSample)
        
        // 에너지 소모 (약 350 kcal)
        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        let energySample = HKQuantitySample(type: energyType, quantity: HKQuantity(unit: .kilocalorie(), doubleValue: 350), start: startDate, end: endDate)
        samples.append(energySample)
        
        
        // completion handler를 async로 변환
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            builder.add(samples) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: success)
            }
        }
        
        try await builder.endCollection(at: endDate)
        
        let workout = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKWorkout?, Error>) in
            builder.finishWorkout { workout, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: workout)
            }
        }
        
        guard let savedWorkout = workout else {
            throw HealthError.failedToLoadWorkoutData
        }
        
        // 3. 경로 데이터 추가 (한강 공원 부근)
        try await addRouteData(to: savedWorkout, store: store, start: startDate, duration: duration)
        
        print("✅ Mock Workout Created: \(savedWorkout)")
        return savedWorkout
    }
    
    // 경로 데이터 추가 헬퍼
    private static func addRouteData(to workout: HKWorkout, store: HKHealthStore, start: Date, duration: TimeInterval) async throws {
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: store, device: .local())
        
        // 예시: 여의도 한강공원 부근 경로 생성
        var locations: [CLLocation] = []
        let startLat = 37.528
        let startLon = 126.932
        
        for i in 0..<Int(duration / 5) {
            // 동쪽으로 조금씩 이동하며 랜덤 변동 추가
            let lat = startLat + (Double.random(in: -0.0001...0.0001))
            let lon = startLon + (Double(i) * 0.0001)
            let time = start.addingTimeInterval(Double(i) * 5)
            
            let location = CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                altitude: 10,
                horizontalAccuracy: 5,
                verticalAccuracy: 5,
                timestamp: time
            )
            locations.append(location)
        }
        
        _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            routeBuilder.insertRouteData(locations) { success, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: success)
            }
        }
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            routeBuilder.finishRoute(with: workout, metadata: nil) { workoutRoute, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                continuation.resume(returning: ())
            }
        }
    }
}

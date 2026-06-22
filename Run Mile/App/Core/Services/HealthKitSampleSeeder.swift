//
//  HealthKitSampleSeeder.swift
//  Run Mile
//
//  Created by Codex on 6/18/26.
//

import CoreLocation
import Foundation
import HealthKit


struct HealthKitSampleSeeder: HealthKitSampleSeeding {
    private static let didSeedSampleKey = "HealthKitSampleSeeder.didSeedSample.seoulRoutes.v1"

    private let store = HKHealthStore()
    private let defaults = UserDefaults.standard

    /// Debug Simulator에서 HealthKit 권한 요청 이후 테스트 러닝 샘플을 명시적으로 생성합니다.
    func seedSampleIfNeeded() async {
        #if DEBUG && targetEnvironment(simulator)
        guard !defaults.bool(forKey: Self.didSeedSampleKey) else { return }

        do {
            let workouts = try await createDetailedRunningWorkouts()
            defaults.set(true, forKey: Self.didSeedSampleKey)
            print("[HealthKitSampleSeeder] seeded sample workouts: \(workouts.map(\.uuid))")
        } catch {
            print("[HealthKitSampleSeeder] failed to seed sample: \(error.localizedDescription)")
        }
        #endif
    }
}


#if DEBUG && targetEnvironment(simulator)
private extension HealthKitSampleSeeder {
    func createDetailedRunningWorkouts() async throws -> [HKWorkout] {
        var workouts: [HKWorkout] = []

        for plan in makeSampleRunPlans(referenceDate: Date()) {
            let workout = try await createDetailedRunningWorkout(plan: plan)
            workouts.append(workout)
        }

        return workouts
    }

    func createDetailedRunningWorkout(plan: SampleRunPlan) async throws -> HKWorkout {
        let config = HKWorkoutConfiguration()
        config.activityType = .running
        config.locationType = .outdoor

        let builder = HKWorkoutBuilder(
            healthStore: store,
            configuration: config,
            device: .local()
        )

        let routePoints = makeRoutePoints(plan: plan, startDate: plan.startDate)
        let startDate = plan.startDate
        let duration = routePoints.last?.elapsedTime ?? 0
        let endDate = startDate.addingTimeInterval(duration)

        try await builder.beginCollection(at: startDate)

        let samples = makeWorkoutSamples(plan: plan, routePoints: routePoints, endDate: endDate)
        let didAddSamples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            builder.add(samples) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: success)
            }
        }

        guard didAddSamples else { throw HealthError.failedToLoadWorkoutData }

        try await builder.endCollection(at: endDate)

        let workout = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<HKWorkout?, Error>) in
            builder.finishWorkout { workout, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: workout)
            }
        }

        guard let savedWorkout = workout else {
            throw HealthError.failedToLoadWorkoutData
        }

        try await addRouteData(to: savedWorkout, locations: routePoints.map(\.location))
        return savedWorkout
    }

    func makeWorkoutSamples(
        plan: SampleRunPlan,
        routePoints: [SampleRoutePoint],
        endDate: Date
    ) -> [HKSample] {
        var samples: [HKSample] = []
        let duration = routePoints.last?.elapsedTime ?? 0
        let startDate = plan.startDate

        for elapsed in stride(from: 0.0, through: duration, by: 10.0) {
            let routePoint = interpolatedRoutePoint(at: elapsed, in: routePoints)
            let time = startDate.addingTimeInterval(elapsed)
            let progress = min(max(routePoint.distance / plan.distanceMeters, 0), 1)
            let paceSeconds = 1_000 / routePoint.speed
            let intensity = min(max((420 - paceSeconds) / 180, 0), 1)
            let wave = sin(progress * .pi * 8)

            let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
            samples.append(
                HKQuantitySample(
                    type: heartRateType,
                    quantity: HKQuantity(
                        unit: .count().unitDivided(by: .minute()),
                        doubleValue: 132 + intensity * 42 + wave * 5
                    ),
                    start: time,
                    end: time
                )
            )

            let speedType = HKQuantityType.quantityType(forIdentifier: .runningSpeed)!
            samples.append(
                HKQuantitySample(
                    type: speedType,
                    quantity: HKQuantity(
                        unit: .meter().unitDivided(by: .second()),
                        doubleValue: routePoint.speed
                    ),
                    start: time,
                    end: time
                )
            )

            let powerType = HKQuantityType.quantityType(forIdentifier: .runningPower)!
            samples.append(
                HKQuantitySample(
                    type: powerType,
                    quantity: HKQuantity(unit: .watt(), doubleValue: 205 + intensity * 90 + wave * 10),
                    start: time,
                    end: time
                )
            )

            let verticalOscillationType = HKQuantityType.quantityType(forIdentifier: .runningVerticalOscillation)!
            samples.append(
                HKQuantitySample(
                    type: verticalOscillationType,
                    quantity: HKQuantity(
                        unit: .meterUnit(with: .centi),
                        doubleValue: 7.4 + intensity * 1.2 + wave * 0.35
                    ),
                    start: time,
                    end: time
                )
            )

            let groundContactTimeType = HKQuantityType.quantityType(forIdentifier: .runningGroundContactTime)!
            samples.append(
                HKQuantitySample(
                    type: groundContactTimeType,
                    quantity: HKQuantity(
                        unit: .secondUnit(with: .milli),
                        doubleValue: 276 - intensity * 48 - wave * 5
                    ),
                    start: time,
                    end: time
                )
            )

            let strideLengthType = HKQuantityType.quantityType(forIdentifier: .runningStrideLength)!
            samples.append(
                HKQuantitySample(
                    type: strideLengthType,
                    quantity: HKQuantity(unit: .meter(), doubleValue: 1.02 + intensity * 0.34 + wave * 0.03),
                    start: time,
                    end: time
                )
            )
        }

        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        samples.append(
            HKQuantitySample(
                type: distanceType,
                quantity: HKQuantity(unit: .meter(), doubleValue: plan.distanceMeters),
                start: startDate,
                end: endDate
            )
        )

        let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
        samples.append(
            HKQuantitySample(
                type: energyType,
                quantity: HKQuantity(unit: .kilocalorie(), doubleValue: plan.distanceMeters / 1_000 * 66),
                start: startDate,
                end: endDate
            )
        )

        return samples
    }

    func addRouteData(to workout: HKWorkout, locations: [CLLocation]) async throws {
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: store, device: .local())

        let didInsertRoute = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            routeBuilder.insertRouteData(locations) { success, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: success)
            }
        }

        guard didInsertRoute else { throw HealthError.failedToLoadWorkoutData }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            routeBuilder.finishRoute(with: workout, metadata: nil) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                continuation.resume(returning: ())
            }
        }
    }

    /// 실제 서울 러닝 코스 형태를 따라 target distance까지 route point를 생성합니다.
    func makeRoutePoints(plan: SampleRunPlan, startDate: Date) -> [SampleRoutePoint] {
        let distanceStep = 25.0
        var points: [SampleRoutePoint] = []
        var elapsedTime: TimeInterval = 0
        var previousDistance = 0.0
        var previousSpeed = speed(for: plan, progress: 0)

        for distance in stride(from: 0.0, through: plan.distanceMeters, by: distanceStep) {
            let progress = min(max(distance / plan.distanceMeters, 0), 1)
            let position = routePosition(at: distance, waypoints: plan.waypoints)
            let speed = speed(for: plan, progress: progress)

            if !points.isEmpty {
                let segmentDistance = distance - previousDistance
                elapsedTime += segmentDistance / ((previousSpeed + speed) / 2)
            }

            points.append(
                SampleRoutePoint(
                    location: CLLocation(
                        coordinate: position.coordinate,
                        altitude: position.altitude,
                        horizontalAccuracy: 5,
                        verticalAccuracy: 4,
                        timestamp: startDate.addingTimeInterval(elapsedTime)
                    ),
                    elapsedTime: elapsedTime,
                    distance: distance,
                    speed: speed
                )
            )

            previousDistance = distance
            previousSpeed = speed
        }

        if (points.last?.distance ?? 0) < plan.distanceMeters {
            let progress = 1.0
            let position = routePosition(at: plan.distanceMeters, waypoints: plan.waypoints)
            let speed = speed(for: plan, progress: progress)
            let segmentDistance = plan.distanceMeters - previousDistance
            elapsedTime += segmentDistance / ((previousSpeed + speed) / 2)

            points.append(
                SampleRoutePoint(
                    location: CLLocation(
                        coordinate: position.coordinate,
                        altitude: position.altitude,
                        horizontalAccuracy: 5,
                        verticalAccuracy: 4,
                        timestamp: startDate.addingTimeInterval(elapsedTime)
                    ),
                    elapsedTime: elapsedTime,
                    distance: plan.distanceMeters,
                    speed: speed
                )
            )
        }

        return points
    }

    func interpolatedRoutePoint(at elapsedTime: TimeInterval, in points: [SampleRoutePoint]) -> SampleRoutePoint {
        guard let firstPoint = points.first,
              let lastPoint = points.last else {
            return SampleRoutePoint(
                location: CLLocation(latitude: 37.5271, longitude: 126.9328),
                elapsedTime: 0,
                distance: 0,
                speed: 2.5
            )
        }

        guard elapsedTime > firstPoint.elapsedTime else { return firstPoint }
        guard elapsedTime < lastPoint.elapsedTime else { return lastPoint }

        guard let nextIndex = points.firstIndex(where: { $0.elapsedTime >= elapsedTime }) else {
            return lastPoint
        }

        let previousPoint = points[points.index(before: nextIndex)]
        let nextPoint = points[nextIndex]
        let segmentDuration = nextPoint.elapsedTime - previousPoint.elapsedTime
        let progress = segmentDuration > 0 ? (elapsedTime - previousPoint.elapsedTime) / segmentDuration : 0
        let coordinate = interpolateCoordinate(
            from: previousPoint.location.coordinate,
            to: nextPoint.location.coordinate,
            progress: progress
        )
        let altitude = previousPoint.location.altitude + ((nextPoint.location.altitude - previousPoint.location.altitude) * progress)
        let distance = previousPoint.distance + ((nextPoint.distance - previousPoint.distance) * progress)
        let speed = previousPoint.speed + ((nextPoint.speed - previousPoint.speed) * progress)

        return SampleRoutePoint(
            location: CLLocation(
                coordinate: coordinate,
                altitude: altitude,
                horizontalAccuracy: 5,
                verticalAccuracy: 4,
                timestamp: previousPoint.location.timestamp.addingTimeInterval(segmentDuration * progress)
            ),
            elapsedTime: elapsedTime,
            distance: distance,
            speed: speed
        )
    }

    func routePosition(
        at targetDistance: CLLocationDistance,
        waypoints: [SampleRouteWaypoint]
    ) -> (coordinate: CLLocationCoordinate2D, altitude: CLLocationDistance) {
        guard let firstWaypoint = waypoints.first,
              let lastWaypoint = waypoints.last else {
            return (CLLocationCoordinate2D(latitude: 37.5271, longitude: 126.9328), 15)
        }

        guard targetDistance > 0 else {
            return (firstWaypoint.coordinate, firstWaypoint.altitude)
        }

        var accumulatedDistance: CLLocationDistance = 0

        for (start, end) in zip(waypoints, waypoints.dropFirst()) {
            let segmentDistance = start.location.distance(from: end.location)
            guard segmentDistance > 0 else { continue }

            if accumulatedDistance + segmentDistance >= targetDistance {
                let progress = (targetDistance - accumulatedDistance) / segmentDistance
                let coordinate = interpolateCoordinate(
                    from: start.coordinate,
                    to: end.coordinate,
                    progress: progress
                )
                let altitude = start.altitude + ((end.altitude - start.altitude) * progress)
                return (coordinate, altitude)
            }

            accumulatedDistance += segmentDistance
        }

        return (lastWaypoint.coordinate, lastWaypoint.altitude)
    }

    func interpolateCoordinate(
        from start: CLLocationCoordinate2D,
        to end: CLLocationCoordinate2D,
        progress: Double
    ) -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: start.latitude + ((end.latitude - start.latitude) * progress),
            longitude: start.longitude + ((end.longitude - start.longitude) * progress)
        )
    }

    func speed(for plan: SampleRunPlan, progress: Double) -> Double {
        let wave = sin(progress * .pi * plan.paceWaveCount)
        let secondaryWave = sin(progress * .pi * 2.5 + plan.pacePhase)
        let paceSecondsPerKilometer = min(
            max(plan.basePace + wave * plan.paceAmplitude + secondaryWave * 12, 240),
            420
        )

        return 1_000 / paceSecondsPerKilometer
    }

    func makeSampleRunPlans(referenceDate: Date) -> [SampleRunPlan] {
        [
            SampleRunPlan(
                distanceMeters: 10_000,
                startDate: referenceDate.addingTimeInterval(-86_400),
                basePace: 318,
                paceAmplitude: 32,
                paceWaveCount: 5,
                pacePhase: 0.4,
                waypoints: yeouidoRouteWaypoints
            ),
            SampleRunPlan(
                distanceMeters: 20_000,
                startDate: referenceDate.addingTimeInterval(-172_800),
                basePace: 344,
                paceAmplitude: 38,
                paceWaveCount: 7,
                pacePhase: 1.1,
                waypoints: cheonggyeHanRiverRouteWaypoints
            ),
            SampleRunPlan(
                distanceMeters: 30_000,
                startDate: referenceDate.addingTimeInterval(-259_200),
                basePace: 368,
                paceAmplitude: 44,
                paceWaveCount: 9,
                pacePhase: 1.8,
                waypoints: hanRiverNamsanRouteWaypoints
            )
        ]
    }

    var yeouidoRouteWaypoints: [SampleRouteWaypoint] {
        [
            .init(37.5271, 126.9328, 14),
            .init(37.5287, 126.9245, 13),
            .init(37.5317, 126.9149, 16),
            .init(37.5260, 126.9129, 18),
            .init(37.5180, 126.9195, 13),
            .init(37.5170, 126.9292, 11),
            .init(37.5216, 126.9366, 12),
            .init(37.5271, 126.9328, 14),
            .init(37.5292, 126.9230, 15),
            .init(37.5223, 126.9180, 17),
            .init(37.5170, 126.9292, 11),
            .init(37.5239, 126.9347, 13),
            .init(37.5271, 126.9328, 14)
        ]
    }

    var cheonggyeHanRiverRouteWaypoints: [SampleRouteWaypoint] {
        [
            .init(37.5759, 126.9768, 34),
            .init(37.5704, 126.9829, 31),
            .init(37.5690, 126.9990, 28),
            .init(37.5681, 127.0168, 27),
            .init(37.5660, 127.0370, 25),
            .init(37.5595, 127.0413, 24),
            .init(37.5475, 127.0475, 18),
            .init(37.5381, 127.0580, 16),
            .init(37.5317, 127.0668, 15),
            .init(37.5208, 127.0814, 14),
            .init(37.5145, 127.0995, 13),
            .init(37.5132, 127.1137, 15),
            .init(37.5206, 127.1217, 22),
            .init(37.5280, 127.1187, 25),
            .init(37.5324, 127.1059, 19),
            .init(37.5310, 127.0902, 16),
            .init(37.5290, 127.0765, 15),
            .init(37.5317, 127.0668, 15),
            .init(37.5400, 127.0585, 17),
            .init(37.5475, 127.0475, 18)
        ]
    }

    var hanRiverNamsanRouteWaypoints: [SampleRouteWaypoint] {
        [
            .init(37.5271, 126.9328, 14),
            .init(37.5216, 126.9366, 12),
            .init(37.5134, 126.9436, 13),
            .init(37.5109, 126.9633, 14),
            .init(37.5139, 126.9882, 15),
            .init(37.5150, 127.0100, 15),
            .init(37.5200, 127.0286, 16),
            .init(37.5298, 127.0524, 18),
            .init(37.5317, 127.0668, 15),
            .init(37.5290, 127.0765, 15),
            .init(37.5310, 127.0902, 16),
            .init(37.5324, 127.1059, 19),
            .init(37.5280, 127.1187, 25),
            .init(37.5206, 127.1217, 22),
            .init(37.5132, 127.1137, 15),
            .init(37.5145, 127.0995, 13),
            .init(37.5208, 127.0814, 14),
            .init(37.5317, 127.0668, 15),
            .init(37.5446, 127.0447, 20),
            .init(37.5531, 127.0342, 35),
            .init(37.5588, 127.0134, 45),
            .init(37.5512, 126.9882, 238),
            .init(37.5472, 126.9808, 96),
            .init(37.5514, 126.9908, 185),
            .init(37.5609, 126.9956, 55),
            .init(37.5704, 126.9829, 31),
            .init(37.5759, 126.9768, 34)
        ]
    }
}


private struct SampleRunPlan {
    let distanceMeters: Double
    let startDate: Date
    let basePace: Double
    let paceAmplitude: Double
    let paceWaveCount: Double
    let pacePhase: Double
    let waypoints: [SampleRouteWaypoint]
}


private struct SampleRouteWaypoint {
    let latitude: Double
    let longitude: Double
    let altitude: CLLocationDistance

    init(_ latitude: Double, _ longitude: Double, _ altitude: CLLocationDistance) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
}


private struct SampleRoutePoint {
    let location: CLLocation
    let elapsedTime: TimeInterval
    let distance: CLLocationDistance
    let speed: Double
}
#endif

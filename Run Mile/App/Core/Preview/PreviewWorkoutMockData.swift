//
//  PreviewWorkoutMockData.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import CoreLocation
import Foundation


enum PreviewWorkoutMockData {
    static let detail: WorkoutDetailData = {
        let workout = PreviewShoesMockData.primaryWorkout
        let startDate = workout.workout.startDate
        let duration = Int(workout.time)
        let step = 180
        let samples = stride(from: 0, through: duration, by: step).map { seconds in
            makeSample(seconds: seconds, startDate: startDate)
        }
        let routes = makeRoutes(startDate: startDate, duration: duration, step: 60)
        
        var detail = WorkoutDetailData()
        detail.heartRate = samples.map {
            UnifiedWorkoutDetailData(seconds: $0.seconds, date: $0.date, value: $0.heartRate)
        }
        detail.runningPace = samples.map {
            UnifiedWorkoutDetailData(seconds: $0.seconds, date: $0.date, value: $0.speed)
        }
        detail.power = samples.map {
            UnifiedWorkoutDetailData(seconds: $0.seconds, date: $0.date, value: $0.power)
        }
        detail.verticalOscillation = samples.map {
            UnifiedWorkoutDetailData(seconds: $0.seconds, date: $0.date, value: $0.verticalOscillation)
        }
        detail.groundContactTime = samples.map {
            UnifiedWorkoutDetailData(seconds: $0.seconds, date: $0.date, value: $0.groundContactTime)
        }
        detail.strideLength = samples.map {
            UnifiedWorkoutDetailData(seconds: $0.seconds, date: $0.date, value: $0.strideLength)
        }
        detail.splits = makeSplits()
        detail.cadence = 174
        detail.routes = routes
        detail.routeSegments = makeRouteSegments(routes: routes)
        return detail
    }()
    
    /// 운동 목록 Preview에서 운동별 등록 신발 상태를 표시하기 위한 샘플 매핑입니다.
    static let workoutShoeRegistrationInfo: [UUID: WorkoutShoeRegistrationInfo] = [
        PreviewShoesMockData.workouts[0].id: WorkoutShoeRegistrationInfo(
            shoeName: PreviewShoesMockData.hallOfFameShoes[0].shoesName,
            isGraduated: true
        ),
        PreviewShoesMockData.workouts[1].id: WorkoutShoeRegistrationInfo(
            shoeName: PreviewShoesMockData.shoes[0].shoesName,
            isGraduated: false
        ),
        PreviewShoesMockData.workouts[3].id: WorkoutShoeRegistrationInfo(
            shoeName: PreviewShoesMockData.shoes[1].shoesName,
            isGraduated: false
        )
    ]
    
    private static func makeSample(seconds: Int, startDate: Date) -> WorkoutMetricSample {
        let progress = Double(seconds) / 3100
        let wave = sin(progress * .pi * 5)
        
        return WorkoutMetricSample(
            seconds: seconds,
            date: startDate.addingTimeInterval(TimeInterval(seconds)),
            heartRate: 136 + progress * 38 + wave * 5,
            speed: 2.72 + progress * 0.58 + wave * 0.16,
            power: 218 + progress * 54 + wave * 12,
            verticalOscillation: 7.8 + wave * 0.45,
            groundContactTime: 245 - progress * 24 + wave * 5,
            strideLength: 1.05 + progress * 0.18 + wave * 0.04
        )
    }
    
    private static func makeRoutes(startDate: Date, duration: Int, step: Int) -> [CLLocation] {
        stride(from: 0, through: duration, by: step).map { seconds in
            let index = Double(seconds / step)
            let latitude = 37.5268 + index * 0.00018
            let longitude = 126.9250 + sin(index / 5) * 0.0014
            let altitude = 28 + sin(index / 4) * 11 + index * 0.12
            
            return CLLocation(
                coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                altitude: altitude,
                horizontalAccuracy: 6,
                verticalAccuracy: 5,
                timestamp: startDate.addingTimeInterval(TimeInterval(seconds))
            )
        }
    }
    
    private static func makeRouteSegments(routes: [CLLocation]) -> [WorkoutRouteSegment] {
        zip(routes, routes.dropFirst()).enumerated().map { index, pair in
            let ratio = Double(index) / Double(max(routes.count - 2, 1))
            return WorkoutRouteSegment(
                coordinates: [pair.0.coordinate, pair.1.coordinate],
                averageSpeed: 2.8 + ratio * 0.55,
                paceRatio: ratio
            )
        }
    }
    
    private static func makeSplits() -> [SplitInfo] {
        [
            SplitInfo(label: "1 km", duration: 322, pace: "5'22\""),
            SplitInfo(label: "2 km", duration: 315, pace: "5'15\""),
            SplitInfo(label: "3 km", duration: 306, pace: "5'06\""),
            SplitInfo(label: "4 km", duration: 298, pace: "4'58\""),
            SplitInfo(label: "5 km", duration: 304, pace: "5'04\""),
            SplitInfo(label: "6 km", duration: 292, pace: "4'52\"")
        ]
    }
}


private struct WorkoutMetricSample {
    let seconds: Int
    let date: Date
    let heartRate: Double
    let speed: Double
    let power: Double
    let verticalOscillation: Double
    let groundContactTime: Double
    let strideLength: Double
}
#endif

//
//  PreviewShoesMockData.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import Foundation
import HealthKit


enum PreviewShoesMockData {
    static let monthlyRunningDistance: Double = 128.4
    static let workouts: [Workout] = [
        makeWorkout(daysAgo: 1, distance: 10240, duration: 3100, calories: 612),
        makeWorkout(daysAgo: 4, distance: 8200, duration: 2520, calories: 486),
        makeWorkout(daysAgo: 8, distance: 12500, duration: 3920, calories: 721),
        makeWorkout(daysAgo: 34, distance: 6200, duration: 2280, calories: 356),
        makeWorkout(daysAgo: 39, distance: 7400, duration: 2700, calories: 421)
    ]
    
    static let shoes: [Shoes] = [
        Shoes(
            id: UUID(uuidString: "3D87E0D2-44D3-4C7E-B84D-6A7F9A4C74D1") ?? UUID(),
            image: placeholderImageData,
            shoesName: "Nike Alphafly 3",
            nickname: "레이스 데이",
            goalMileage: 800,
            currentMileage: 84,
            workouts: Array(workouts.prefix(3))
        ),
        Shoes(
            id: UUID(uuidString: "5D241D30-AE71-4FC2-A9D8-22B6C647E0BD") ?? UUID(),
            image: placeholderImageData,
            shoesName: "Asics Novablast 4",
            nickname: "데일리 조깅",
            goalMileage: 700,
            currentMileage: 212,
            workouts: Array(workouts.suffix(2))
        ),
        Shoes(
            id: UUID(uuidString: "4B42030B-B259-4185-9D73-24472921C588") ?? UUID(),
            image: placeholderImageData,
            shoesName: "Hoka Clifton 9",
            nickname: "회복런",
            goalMileage: 650,
            currentMileage: 552,
            workouts: [
                makeWorkout(daysAgo: 3, distance: 5100, duration: 2070, calories: 286)
            ]
        )
    ]
    
    static let hallOfFameShoes: [Shoes] = [
        Shoes(
            id: UUID(uuidString: "86E0947D-D1CC-438E-9BB2-FBE27540E422") ?? UUID(),
            image: placeholderImageData,
            shoesName: "Adidas Adizero Adios Pro 3",
            nickname: "첫 풀코스",
            goalMileage: 600,
            currentMileage: 624,
            workouts: Array(workouts.prefix(2)),
            isGraduate: true
        ),
        Shoes(
            id: UUID(uuidString: "E947029C-C831-4DE8-9444-925C1B2F3D5F") ?? UUID(),
            image: placeholderImageData,
            shoesName: "New Balance 1080v13",
            nickname: "겨울 훈련화",
            goalMileage: 700,
            currentMileage: 732,
            workouts: Array(workouts.suffix(2)),
            isGraduate: true
        )
    ]
    
    static var primaryShoes: Shoes {
        shoes[0]
    }
    
    static var primaryWorkout: Workout {
        workouts[0]
    }
    
    private static let placeholderImageData = Data()
    
    /// 신발 Preview에서 사용하는 가벼운 HKWorkout 샘플을 생성합니다.
    private static func makeWorkout(
        daysAgo: Int,
        distance: Double,
        duration: TimeInterval,
        calories: Double
    ) -> Workout {
        let endDate = referenceDate.addingTimeInterval(-Double(daysAgo) * 24 * 60 * 60)
        let startDate = endDate.addingTimeInterval(-duration)
        let workout = HKWorkout(
            activityType: .running,
            start: startDate,
            end: endDate,
            duration: duration,
            totalEnergyBurned: HKQuantity(unit: .kilocalorie(), doubleValue: calories),
            totalDistance: HKQuantity(unit: .meter(), doubleValue: distance),
            metadata: nil
        )
        
        return Workout(workout: workout)
    }
    
    private static let referenceDate: Date = {
        Calendar.current.date(
            from: DateComponents(year: 2026, month: 5, day: 8, hour: 7, minute: 30)
        ) ?? Date()
    }()
}
#endif

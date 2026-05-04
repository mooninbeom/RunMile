//
//  WorkoutDetailData.swift
//  Run Mile
//
//  Created by 문인범 on 12/30/25.
//

import Foundation
import CoreLocation


struct WorkoutDetailData {
    let id = UUID()
    
    var heartRate: [UnifiedWorkoutDetailData] = []
    var runningPace: [UnifiedWorkoutDetailData] = []
    var power: [UnifiedWorkoutDetailData] = []
    var verticalOscillation: [UnifiedWorkoutDetailData] = []
    var groundContactTime: [UnifiedWorkoutDetailData] = []
    var strideLength: [UnifiedWorkoutDetailData] = []
    var splits: [SplitInfo] = []
    var cadence: Double?
    
    var routes: [CLLocation] = []
    var routeSegments: [WorkoutRouteSegment] = []
}


struct UnifiedWorkoutDetailData: Identifiable {
    let id = UUID()
    let seconds: Int    // 경과 시간
    let date: Date      // 실제 날짜
    
    let value: Double?
}

struct SplitInfo: Identifiable {
    let id = UUID()
    let label: String
    let duration: TimeInterval
    let pace: String
}

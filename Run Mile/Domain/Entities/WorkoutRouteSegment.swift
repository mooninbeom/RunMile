//
//  WorkoutRouteSegment.swift
//  Run Mile
//
//  Created by Codex on 5/3/26.
//

import CoreLocation


struct WorkoutRouteSegment: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let averageSpeed: Double
    let paceRatio: Double
}

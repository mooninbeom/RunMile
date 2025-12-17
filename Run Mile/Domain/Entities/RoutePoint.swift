//
//  RoutePoint.swift
//  Run Mile
//
//  Created by 문인범 on 12/17/25.
//

import CoreLocation


struct RoutePoint: Hashable {
    let coordinate: CLLocationCoordinate2D
    let timestamp: Date
    let altitude: Double
    
    static func == (lhs: RoutePoint, rhs: RoutePoint) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude &&
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.timestamp == rhs.timestamp &&
        lhs.altitude == rhs.altitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.longitude)
        hasher.combine(coordinate.latitude)
        hasher.combine(timestamp)
        hasher.combine(altitude)
    }
}

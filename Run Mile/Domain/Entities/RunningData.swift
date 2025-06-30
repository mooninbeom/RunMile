//
//  RunningData.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import Foundation

public struct Workout: Sendable, Identifiable, Hashable {
    public let id: UUID
    public let distance: Double
    public let date: Date?
    
    public var calculatedDistance: String {
        let kilometer = self.distance / 1000
        return String(format: "%.2f", kilometer)
    }
}

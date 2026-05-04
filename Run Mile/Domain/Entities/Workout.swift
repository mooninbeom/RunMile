//
//  Workout.swift
//  Run Mile
//
//  Created by 문인범 on 12/17/25.
//

import Foundation
import HealthKit


public struct Workout: Sendable, Identifiable, Hashable {
    let workout: HKWorkout
    
    public var id: UUID { self.workout.uuid }
    
    public var calculatedDistance: String {
        let kilometer = self.distance / 1000
        return String(format: "%.2f", kilometer)
    }
    
    var distance: Double {
        self.workout.getMeterDistance()
    }
    
    var date: Date {
        self.workout.endDate
    }
    
    var avgPace: String {
        self.workout.getAvgPace()
    }
    
    var time: Double {
        self.workout.duration
    }
    
    var activeEnergyBurned: Double {
        self.workout.getActiveEnergyBurned()
    }
    
}

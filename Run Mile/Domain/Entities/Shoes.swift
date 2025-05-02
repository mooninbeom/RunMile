//
//  Shoes.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation


struct Shoes: Sendable, Identifiable, Hashable {
    let id: UUID
    let image: Data
    let shoesName: String
    let nickname: String
    let goalMileage: Double
    let currentMileage: Double
    let workouts: [RunningData]
    let isGradutate: Bool = false
    
    public var getCurrentMileage: String {
        let reducedMileage = workouts.reduce(0){ $0 + $1.distance } / 1000
        return String(format: "%.1f", reducedMileage + currentMileage)
    }
    
    public var getGoalMileage: String {
        String(Int(goalMileage))
    }
}

//
//  ShoesDTO.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import RealmSwift


final class ShoesDTO: Object {
    @Persisted(primaryKey: true) public var id: UUID = .init()
    @Persisted public var createdAt: Date = .init()
    @Persisted public var image: Data
    @Persisted public var shoesName: String
    @Persisted public var nickname: String
    @Persisted public var goalMileage: Double
    @Persisted public var currentMileage: Double
    @Persisted public var isGraduated: Bool = false
    @Persisted public var workouts: List<WorkoutDTO> = .init()
}

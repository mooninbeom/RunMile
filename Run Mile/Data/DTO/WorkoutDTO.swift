//
//  WorkoutDTO.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation
import RealmSwift


final class WorkoutDTO: Object {
    @Persisted(primaryKey: true) public var id: UUID
    @Persisted public var workoutDate: Date
    @Persisted public var distance: Double
}

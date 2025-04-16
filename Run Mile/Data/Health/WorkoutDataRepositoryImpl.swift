//
//  WorkoutDataRepositoryImpl.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import Foundation
import HealthKit


final class WorkoutDataRepositoryImpl: WorkoutDataRepository {
    let store = HKHealthStore()
    
    
    func requestAuthorization() {
        
    }
}

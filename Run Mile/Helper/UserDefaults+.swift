//
//  UserDefaults+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import Foundation


extension UserDefaults {
    public var isFirstLaunch: Bool {
        get {
            self.bool(forKey: "isFirstLaunch")
        }
        set {
            self.set(newValue, forKey: "isFirstLaunch")
        }
    }
    
    public var recentWorkoutID: String {
        get {
            self.string(forKey: "recentWorkoutID") ?? ""
        }
        set {
            self.set(newValue, forKey: "recentWorkoutID")
        }
    }
    
    public var selectedShoesID: String {
        get {
            self.string(forKey: "selectedShoesID") ?? ""
        }
        set {
            self.set(newValue, forKey: "selectedShoesID")
        }
    }
}

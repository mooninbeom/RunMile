//
//  UserDefaults+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import Foundation
import HealthKit


extension UserDefaults {
    enum Key {
        static let selectedShoesID = "selectedShoesID"
        static let isMigratedToCoreData = "isMigratedToCoreData"
        static let lastAnchor = "anchor"
        static let pendingRunningWorkoutIDs = "pendingRunningWorkoutIDs"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }

    public var selectedShoesID: String {
        get {
            self.string(forKey: Key.selectedShoesID) ?? ""
        }
        set {
            self.set(newValue, forKey: Key.selectedShoesID)
        }
    }

    public var isMigratedToCoreData: Bool {
        get {
            self.bool(forKey: Key.isMigratedToCoreData)
        }
        set {
            self.set(newValue, forKey: Key.isMigratedToCoreData)
        }
    }

    public var lastAnchor: HKQueryAnchor? {
        get {
            self.data(forKey: Key.lastAnchor).flatMap {
                try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: $0)
            }
        }
        set {
            if let anchor = newValue,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) {
                self.set(data, forKey: Key.lastAnchor)
            }
        }
    }

    public var pendingRunningWorkoutIDs: [String] {
        get {
            self.stringArray(forKey: Key.pendingRunningWorkoutIDs) ?? []
        }
        set {
            self.set(newValue, forKey: Key.pendingRunningWorkoutIDs)
        }
    }

    public var hasCompletedOnboarding: Bool {
        get {
            self.bool(forKey: Key.hasCompletedOnboarding)
        }
        set {
            self.set(newValue, forKey: Key.hasCompletedOnboarding)
        }
    }
}

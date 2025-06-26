//
//  UserDefaults+.swift
//  Run Mile
//
//  Created by 문인범 on 5/6/25.
//

import Foundation
import HealthKit


extension UserDefaults {
    public var selectedShoesID: String {
        get {
            self.string(forKey: "selectedShoesID") ?? ""
        }
        set {
            self.set(newValue, forKey: "selectedShoesID")
        }
    }
    
    public var lastAnchor: HKQueryAnchor? {
        get {
            self.data(forKey: "anchor").flatMap {
                try? NSKeyedUnarchiver.unarchivedObject(ofClass: HKQueryAnchor.self, from: $0)
            }
        }
        set {
            if let anchor = newValue,
               let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true) {
                self.set(data, forKey: "anchor")
            }
        }
    }
}

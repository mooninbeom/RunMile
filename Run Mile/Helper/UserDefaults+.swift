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
}

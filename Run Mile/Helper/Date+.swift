//
//  Date+.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation


extension Date {
    public var workoutFormatDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd(E)"
        return formatter.string(from: self)
    }
    
    public var yearMonth: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM"
        return formatter.string(from: self)
    }
}

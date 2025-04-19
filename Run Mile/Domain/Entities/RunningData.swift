//
//  RunningData.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import Foundation

struct RunningData: Sendable, Identifiable, Hashable {
    let id: UUID
    let distance: Double
    let date: Date?
}

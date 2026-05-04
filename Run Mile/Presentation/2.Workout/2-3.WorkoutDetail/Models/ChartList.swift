//
//  ChartList.swift
//  Run Mile
//
//  Created by 문인범 on 1/2/26.
//

import Foundation
import SwiftUI


enum ChartList: Int {
    case heart = 1
    case pace = 0
    case power = 2
    case verticalOscillation = 3
    case groundContactTime = 4
    case strideLength = 5
    
    public var labelTitle: String {
        switch self {
        case .heart: "심박수"
        case .pace: "페이스"
        case .power: "파워"
        case .verticalOscillation: "수직 진폭"
        case .groundContactTime: "지면 접촉 시간"
        case .strideLength: "보폭 길이"
        }
    }
    
    public var symbolTitle: String {
        switch self {
        case .heart:
            "heart.fill"
        case .pace:
            "stopwatch"
        case .power:
            "bolt.fill"
        case .verticalOscillation:
            "arrow.up.and.down"
        case .groundContactTime:
            "timer"
        case .strideLength:
            "ruler"
        }
    }
    
    public var color: Color {
        switch self {
        case .heart:
                .red
        case .pace:
                .blue
        case .power:
                .yellow
        case .verticalOscillation:
                .purple
        case .groundContactTime:
                .brown
        case .strideLength:
                .cyan
        }
    }
}


extension ChartList: Identifiable, Comparable {
    var id: Self { self }
    static func < (lhs: ChartList, rhs: ChartList) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

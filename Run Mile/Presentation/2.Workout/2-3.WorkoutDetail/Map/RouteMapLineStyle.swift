//
//  RouteMapLineStyle.swift
//  Run Mile
//
//  Created by Codex on 6/21/26.
//

import SwiftUI


enum RouteMapLineStyle {
    /// 운동 경로를 Apple Fitness처럼 짧은 캡슐 점들이 이어진 형태로 표현합니다.
    static func dottedStroke(lineWidth: CGFloat) -> StrokeStyle {
        StrokeStyle(
            lineWidth: lineWidth,
            lineCap: .round,
            lineJoin: .round,
            dash: [1, lineWidth * 0.8]
        )
    }
}

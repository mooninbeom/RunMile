//
//  Double+.swift
//  Run Mile
//
//  Created by 문인범 on 5/2/25.
//

import Foundation


extension Double {
    public var toInt: Int {
        Int(self)
    }
    
    public func meterPerSecondToPace() -> String {
        guard self > 0 else { return "-'-\"" }
        
        // 1. 1km를 가는 데 걸리는 총 시간(초) 계산
        let secondsPerKm = 1000.0 / self
        
        // 2. 분과 초로 분리
        // 305초 -> 5분
        let minutes = Int(secondsPerKm / 60)
        
        // 305초 % 60 -> 5초
        let seconds = Int(secondsPerKm.truncatingRemainder(dividingBy: 60))
        
        // 3. 포맷팅 (원하는 대로 선택)
        // 러너들이 많이 쓰는 포맷 (예: 5'30")
        return String(format: "%d'%02d\"", minutes, seconds)
        
    }
}

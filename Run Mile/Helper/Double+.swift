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
        
        let secondsPerKm = 1000.0 / self
        let minutes = Int(secondsPerKm / 60)
        let seconds = Int(secondsPerKm.truncatingRemainder(dividingBy: 60))
        
        return String(format: "%d'%02d\"", minutes, seconds)
    }
    
    public func toTimeString() -> String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// 초 단위 경과 시간을 운동 시간 표시에 맞는 H:MM:SS 문자열로 변환합니다.
    public func toHourMinuteSecondString() -> String {
        let totalSeconds = max(0, Int(self))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        return String(format: "%d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// 초 단위 경과 시간을 차트 축에 맞는 H:MM 문자열로 변환합니다.
    public func toHourMinuteString() -> String {
        let totalSeconds = max(0, Int(self))
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        
        return String(format: "%d:%02d", hours, minutes)
    }
}

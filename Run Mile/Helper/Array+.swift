//
//  Array+.swift
//  Run Mile
//
//  Created by 문인범 on 1/2/26.
//

import Foundation


// MARK: - 획득 고도 측정 메소드
import CoreLocation
extension Array<CLLocation> {
    func calculateTotalElevationGain() -> String {
        // 데이터가 충분하지 않으면 0 반환
        guard self.count > 1 else { return "" }
        
        // 1. 1차 필터링: 수직 정확도가 떨어지는 데이터 제외
        // verticalAccuracy가 음수이면 유효하지 않은 데이터, 너무 크면 신뢰도 낮음 (예: 20m 이상)
        let validLocations = self.filter {
            $0.verticalAccuracy >= 0 && $0.verticalAccuracy <= 20.0
        }
        
        guard !validLocations.isEmpty else { return "" }
        
        // 2. 고도 평활화 (Smoothing): 이동 평균 필터 적용
        // GPS 고도는 미세하게 계속 진동하므로, 인접한 값들의 평균을 사용해 노이즈를 줄입니다.
        let windowSize = 5 // 평균을 낼 윈도우 크기 (데이터 조밀도에 따라 3~10 조절)
        var smoothedAltitudes: [Double] = []
        
        for i in 0..<validLocations.count {
            let start = Swift.max(0, i - windowSize / 2)
            let end = Swift.min(validLocations.count, i + windowSize / 2 + 1)
            let window = validLocations[start..<end]
            
            let sum = window.reduce(0) { $0 + $1.altitude }
            let avg = sum / Double(window.count)
            smoothedAltitudes.append(avg)
        }
        
        // 3. 총 상승 고도 계산
        var totalGain: Double = 0.0
        var previousAltitude: Double = smoothedAltitudes.first ?? 0.0
        
        // 노이즈 방지를 위한 최소 변화량 임계값 (예: 0.3m 미만의 미세한 변화는 무시)
        let threshold: Double = 0.3
        
        for altitude in smoothedAltitudes.dropFirst() {
            let diff = altitude - previousAltitude
            
            if diff > threshold {
                // 임계값보다 크게 상승했을 때만 누적
                totalGain += diff
                previousAltitude = altitude // 기준 높이 갱신
            } else if diff < -threshold {
                // 임계값보다 크게 하강했을 때는 기준 높이만 갱신 (내려갔다 다시 올라오는 것 반영 위해)
                previousAltitude = altitude
            }
            // 임계값 이내의 미세한 변화는 무시(previousAltitude 유지)하여 '자글자글한' 노이즈 누적 방지
        }
        
        return String(format: "%.0f",totalGain)
    }
}

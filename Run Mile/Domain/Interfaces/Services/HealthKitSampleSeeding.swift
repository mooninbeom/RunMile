//
//  HealthKitSampleSeeding.swift
//  Run Mile
//
//  Created by Codex on 6/18/26.
//

import Foundation


protocol HealthKitSampleSeeding {
    /// Debug Simulator에서 HealthKit 테스트 운동 샘플이 필요하면 한 번만 생성합니다.
    func seedSampleIfNeeded() async
}

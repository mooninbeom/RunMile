//
//  Shoes.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation


struct Shoes: Sendable, Identifiable, Hashable {
    let id: UUID                        // UUID
    let image: Data                     // 신발 이미지
    let shoesName: String               // 신발 이름
    let nickname: String                // 신발 별명
    let goalMileage: Double             // 목표 마일리지
    let currentMileage: Double          // 초기 마일리지
    let isCurrentShoes: Bool            // 현재 자동등록이 선택된 신발인지 여부
    let workouts: [RunningData]         // 신발에 등록된 운동기록
    let isGradutate: Bool = false       // 신발 졸업 여부
    
    init(id: UUID,
         image: Data,
         shoesName: String,
         nickname: String,
         goalMileage: Double,
         currentMileage: Double,
         workouts: [RunningData]
    ) {
        self.id = id
        self.image = image
        self.shoesName = shoesName
        self.nickname = nickname
        self.goalMileage = goalMileage
        self.currentMileage = currentMileage
        self.workouts = workouts
        
        // 현재 자동 등록이 된 신발인지 여부 판단
        self.isCurrentShoes = UserDefaults.standard.selectedShoesID == id.uuidString
    }
    
    /// 등록된 운동 + 기존 마일리지로 계산한 현재 신발의 마일리지
    public var getCurrentMileage: String {
        let reducedMileage = workouts.reduce(0){ $0 + $1.distance } / 1000
        return String(format: "%.2f", reducedMileage + currentMileage)
    }
    
    /// 목표 마일리지 String값 반환
    public var getGoalMileage: String {
        String(Int(goalMileage))
    }
    
    /// 목표 마일리지를 넘어섰는지 여부 판단
    public var isOverGoal: Bool {
        let reducedMileage = workouts.reduce(0){ $0 + $1.distance } / 1000 + currentMileage
        return reducedMileage > goalMileage
    }
}

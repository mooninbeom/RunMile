//
//  ShoePresentationInfo.swift
//  Run Mile
//
//  Created by Codex on 5/7/26.
//

import SwiftUI


struct ShoePresentationInfo: Identifiable {
    let shoe: Shoes
    
    var id: UUID {
        shoe.id
    }
    
    var brand: String {
        let components = shoe.shoesName.split(separator: " ")
        return components.first.map(String.init) ?? "BRAND"
    }
    
    var model: String {
        let components = shoe.shoesName.split(separator: " ")
        
        if components.count > 1 {
            return components.dropFirst().joined(separator: " ")
        }
        
        return shoe.shoesName
    }
    
    var lifeSpanRatio: Double {
        guard shoe.goalMileage > 0 else { return 0 }
        return min(shoe.totalMileage / shoe.goalMileage, 1.0)
    }
    
    var remainingPercentText: String {
        "\(Int((1.0 - lifeSpanRatio) * 100))% 남음"
    }
    
    var currentMileageText: String {
        "\(Int(shoe.totalMileage))km"
    }
    
    var goalMileageText: String {
        "\(Int(shoe.goalMileage))km"
    }
    
    var statusColor: Color {
        switch lifeSpanRatio {
        case 0..<0.5:
            return RunMileColor.chart4
        case 0.5..<0.8:
            return RunMileColor.secondary
        default:
            return RunMileColor.primary
        }
    }
    
    var statusForegroundColor: Color {
        lifeSpanRatio < 0.8
        ? RunMileColor.secondaryForeground
        : RunMileColor.primaryForeground
    }
}

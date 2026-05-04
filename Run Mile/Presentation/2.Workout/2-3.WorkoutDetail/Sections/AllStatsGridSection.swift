//
//  AllStatsGridSection.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI


struct AllStatsGridSection: View {
    @Binding var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
            StatCard(title: "평균 페이스", value: viewModel.avgPace, unit: "/km", icon: "stopwatch", color: .blue)
            
            if let avgHeartRate = viewModel.avgHeartRate {
                StatCard(title: "평균 심박수", value: avgHeartRate, unit: "BPM", icon: "heart.fill", color: .red)
            }
            
            if let elevationGain = viewModel.elevationGain {
                StatCard(title: "고도 상승", value: elevationGain, unit: "m", icon: "arrow.up.right", color: .green)
            }
            
            if let avgPower = viewModel.avgPower {
                StatCard(title: "평균 파워", value: avgPower, unit: "W", icon: "bolt.fill", color: .yellow)
            }
            
            if let avgCadence = viewModel.avgCadence {
                StatCard(title: "케이던스", value: avgCadence, unit: "SPM", icon: "figure.run", color: .orange)
            }
            
            if let avgVerticalOscillation = viewModel.avgVerticalOscillation {
                StatCard(title: "수직 진폭", value: avgVerticalOscillation, unit: "cm", icon: "arrow.up.and.down", color: .purple)
            }
            
            if let avgGroundContactTime = viewModel.avgGroundContactTime {
                StatCard(title: "지면 접촉 시간", value: avgGroundContactTime, unit: "ms", icon: "timer", color: .brown)
            }
            
            if let avgStrideLength = viewModel.avgStrideLength {
                StatCard(title: "보폭 길이", value: avgStrideLength, unit: "m", icon: "ruler", color: .cyan)
            }
        }
        .padding(.horizontal)
    }
}

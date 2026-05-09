//
//  ShoesDetailMileageCardView.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ShoesDetailMileageCardView: View {
    let shoes: Shoes
    let remainingPercentText: String
    let lifeSpanRatio: Double
    let statusColor: Color
    let statusForegroundColor: Color
    let averageDistance: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            mileageHeaderView
            progressView
            
            Divider()
            
            detailStatsView
        }
        .padding(20)
        .runMileBrutalCard()
        .padding(.horizontal)
    }
    
    private var mileageHeaderView: some View {
        HStack {
            Label("마일리지 상태", systemImage: "chart.bar.fill")
                .font(.headline)
                .foregroundStyle(RunMileColor.foreground)
            
            Spacer()
            
            Text(remainingPercentText)
                .font(.caption)
                .fontWeight(.bold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .fill(statusColor)
                }
                .foregroundStyle(statusForegroundColor)
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }
        }
    }
    
    private var progressView: some View {
        VStack(spacing: 8) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .fill(RunMileColor.muted)
                        .frame(height: 12)
                    
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .fill(statusColor)
                        .frame(width: geometry.size.width * max(lifeSpanRatio, 0.05), height: 12)
                }
            }
            .frame(height: 12)
            
            HStack {
                Text(shoes.getCurrentMileage + "km")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(statusColor)
                
                Text("사용")
                    .font(.caption)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(.leading, -4)
                
                Spacer()
                
                Text(shoes.getGoalMileage + "km")
                    .font(.headline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Text("목표")
                    .font(.caption)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(.leading, -4)
            }
            .padding(.top, 4)
        }
    }
    
    private var detailStatsView: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("주행 횟수")
                    .font(.caption)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Text("\(shoes.workouts.count)회")
                    .font(.headline)
                    .foregroundStyle(RunMileColor.foreground)
            }
            
            VStack(alignment: .leading) {
                Text("평균 거리")
                    .font(.caption)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Text(averageDistance)
                    .font(.headline)
                    .foregroundStyle(RunMileColor.foreground)
            }
        }
    }
}

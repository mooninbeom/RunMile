//
//  ShoeCardView.swift
//  Run Mile
//
//  Created by Codex on 5/7/26.
//

import SwiftUI


struct ShoeCardView: View {
    let item: ShoePresentationInfo

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            shoeImageView
            shoeInfoView
        }
        .padding(16)
        .runMileBrutalCard()
    }
    
    private var shoeImageView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .fill(RunMileColor.muted)
                .frame(width: 80, height: 80)
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
            
            if let uiImage = UIImage(data: item.shoe.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 70, height: 70)
            } else {
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
        }
    }
    
    private var shoeInfoView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.brand.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Spacer()
                
                remainingBadge
            }
            
            Text(item.model)
                .font(.headline)
                .foregroundStyle(RunMileColor.foreground)
                .lineLimit(1)
            
            Text(item.shoe.nickname)
                .font(.subheadline)
                .foregroundStyle(RunMileColor.mutedForeground)
            
            mileageProgressView
                .padding(.top, 4)
        }
    }
    
    private var remainingBadge: some View {
        Text(item.remainingPercentText)
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                    .fill(item.statusColor)
            }
            .foregroundStyle(item.statusForegroundColor)
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
            }
    }
    
    private var mileageProgressView: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(item.currentMileageText)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.foreground)
                
                Text("/ \(item.goalMileageText)")
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Spacer()
            }
            .font(.caption)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .frame(height: 6)
                        .foregroundStyle(RunMileColor.muted)
                    
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .frame(width: geometry.size.width * max(item.lifeSpanRatio, 0.05), height: 6)
                        .foregroundStyle(item.statusColor)
                }
            }
            .frame(height: 6)
        }
    }
}

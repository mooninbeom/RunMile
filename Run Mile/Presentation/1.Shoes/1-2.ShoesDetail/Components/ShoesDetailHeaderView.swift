//
//  ShoesDetailHeaderView.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI


struct ShoesDetailHeaderView: View {
    let shoes: Shoes
    let brand: String
    let model: String
    let onImageTap: () -> Void
    let onHallOfFameTap: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            shoeImageView
            shoeInfoView
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    private var shoeImageView: some View {
        Group {
            if let uiImage = UIImage(data: shoes.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                    .runMileBrutalCard(cornerRadius: RunMileRadius.image)
                    .onTapGesture(perform: onImageTap)
            } else {
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(30)
                    .runMileBrutalCard(cornerRadius: RunMileRadius.image)
            }
        }
    }
    
    private var shoeInfoView: some View {
        VStack(spacing: 8) {
            Text(brand.uppercased())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(RunMileColor.primaryForeground)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .fill(RunMileColor.primary)
                }
            
            Text(model)
                .font(.title)
                .fontWeight(.heavy)
                .foregroundStyle(RunMileColor.foreground)
                .multilineTextAlignment(.center)
            
            Text("\"\(shoes.nickname)\"")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(RunMileColor.mutedForeground)
            
            if shoes.isGradutate {
                hallOfFameBadge
            }
            
            if !shoes.isGradutate && shoes.isOverGoal {
                hallOfFameButton
            }
        }
    }
    
    private var hallOfFameBadge: some View {
        Label("명예의 전당", systemImage: "laurel.leading")
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(RunMileColor.secondaryForeground)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                    .fill(RunMileColor.secondary)
            }
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
            }
            .padding(.top, 4)
    }
    
    private var hallOfFameButton: some View {
        Button(action: onHallOfFameTap) {
            HStack {
                Image(systemName: "trophy.fill")
                Text("명예의 전당 입성")
            }
            .runMileSecondaryButton()
        }
        .padding(.top, 8)
    }
}

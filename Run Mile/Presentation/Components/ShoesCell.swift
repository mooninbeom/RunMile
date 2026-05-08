//
//  ShoesCell.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import SwiftUI


struct ShoesCell: View {
    let shoes: Shoes
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .foregroundStyle(RunMileColor.card)
                .overlay {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                            .fill(RunMileColor.muted)
                            .frame(width: 120, height: 120)
                            .overlay {
                                if let image = shoes.image.toImage() {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(ContainerRelativeShape())
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                            }
                        
                        ShoeInfoView(shoes: shoes)
                        
                        Spacer()
                        
                    }
                    .padding(20)
                }
            
                RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                    .strokeBorder(lineWidth: RunMileStroke.border)
                    .foregroundStyle(RunMileColor.selection)
                    .opacity(shoes.isCurrentShoes ? 1 : 0)
        }
        .frame(height: 160)
        .runMileBrutalCard()
    }
}


private struct ShoeInfoView: View {
    let shoes: Shoes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(shoes.nickname)
                    .font(FontStyle.shoeName())
                    .padding(.leading, 10)
                    .padding(.top, 10)
                
                Spacer()
            }
            Spacer()
        }
        .overlay {
            HStack(spacing: 0) {
                Text(shoes.getCurrentMileage)
                    .foregroundStyle(shoes.isOverGoal ? RunMileColor.primary : RunMileColor.secondary)
                
                Spacer()
                
                Text("km")
            }
            .font(FontStyle.cellTitle())
            .padding(.leading, 10)
        }
    }
}

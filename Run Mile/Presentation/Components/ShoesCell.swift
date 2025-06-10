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
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.workoutCell)
                .overlay {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 120, height: 120)
                            .overlay {
                                if let image = shoes.image.toImage() {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .clipShape(ContainerRelativeShape())
                                }
                            }
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        ShoeInfoView(shoes: shoes)
                        
                        Spacer()
                        
                    }
                    .padding(20)
                }
            
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(lineWidth: 1)
                    .foregroundStyle(.primary1)
                    .opacity(shoes.isCurrentShoes ? 1 : 0)
        }
        .frame(height: 160)
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
                    .foregroundStyle( shoes.isOverGoal ? .primary1 : .hallOfFame2 )
                
                Spacer()
                
                Text("km")
            }
            .font(FontStyle.cellTitle())
            .padding(.leading, 10)
        }
    }
}

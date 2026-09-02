//
//  ImageDetailView.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import SwiftUI


struct ImageDetailView: View {
    
    let image: Data
    
    var body: some View {
        ZStack {
            RunMileColor.background
                .ignoresSafeArea()

            Group {
                if let image = image.toImage() {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 52, weight: .bold))
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
            }
            .padding(RunMileSpacing.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                    .fill(RunMileColor.surfaceElevated)
                    .shadow(
                        color: RunMileColor.hardShadow,
                        radius: 0,
                        x: RunMileShadow.offset,
                        y: RunMileShadow.offset
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
            .padding(RunMileSpacing.screenHorizontal)
            .padding(.vertical, RunMileSpacing.large)
        }
    }
}

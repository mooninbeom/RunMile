//
//  RouteAnnotationViews.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI


struct SelectedRouteAnnotationView: View {
    let pace: String
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: 22, height: 22)
                .overlay {
                    Circle()
                        .fill(.blue)
                        .frame(width: 13, height: 13)
                }
                .shadow(color: .black.opacity(0.3), radius: 6, x: 0, y: 3)
            
            Text(pace)
                .font(.caption2.weight(.black))
                .monospacedDigit()
                .foregroundStyle(.white)
                .padding(.vertical, 5)
                .padding(.horizontal, 8)
                .background(.black.opacity(0.72), in: Capsule())
                .offset(y: -28)
        }
    }
}


struct FastestPaceAnnotationView: View {
    let pace: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.orange)
            
            Text("최고 \(pace)")
                .font(.caption.weight(.bold))
                .monospacedDigit()
                .foregroundStyle(.white)
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 10)
        .background(.black.opacity(0.68), in: Capsule())
        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
    }
}

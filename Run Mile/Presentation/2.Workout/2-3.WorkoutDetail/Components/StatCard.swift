//
//  StatCard.swift
//  Run Mile
//
//  Created by 문인범 on 1/2/26.
//

import SwiftUI


struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            
            HStack(alignment: .bottom, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.foreground)
                Text(unit)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(.bottom, 2)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .runMileBrutalCard()
    }
}

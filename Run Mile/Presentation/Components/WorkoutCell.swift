//
//  WorkoutCell.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct WorkoutCell: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.workoutCell)
                .frame(height: 80)
                .overlay {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            /// Distance
                            Text("20.34km")
                                .font(FontStyle.cellTitle())
                                .offset(y: 4)
                            
                            /// Date
                            Text("2024.01.01(Mon)")
                                .font(FontStyle.cellSubtitle())
                                .offset(y: -4)
                        }
                        .foregroundStyle(.white)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 15)
                }
        }
    }
}

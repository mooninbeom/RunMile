//
//  WorkoutListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct WorkoutListView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("운동 등록")
                .font(FontStyle.hallOfFame())
                .padding(.horizontal, 20)

            Text("마일리지 등록을 원하는 운동 기록을 선택해주세요!")
                .font(FontStyle.workoutSubtitle())
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(0..<10, id: \.self) { _ in
                        WorkoutCell()
                            .padding(.bottom, 15)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}



private struct WorkoutCell: View {
    var body: some View {
        Button {
            
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


#Preview {
    WorkoutListView()
}

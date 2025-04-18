//
//  WorkoutListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct WorkoutListView: View {
    @State private var viewModel: WorkoutListViewModel = .init()
    
    
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
                        WorkoutCell{
                            viewModel.workoutCellTapped()
                        }
                        .padding(.bottom, 15)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}


#Preview {
    WorkoutListView()
}

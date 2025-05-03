//
//  HOFView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI

struct HOFView: View {
    var body: some View {
        VStack {
            HStack {
                Text("마일리지 목표를 달성한 신발을 보관합니다!")
                    .font(FontStyle.workoutSubtitle())
                
                // TODO: 셀 구현
                
                Spacer()
            }
            
            Spacer()
        }
        .navigationTitle("명예의 전당")
        .navigationBarTitleDisplayMode(.large)
        .padding(.horizontal, 20)
    }
}

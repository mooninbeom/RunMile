//
//  FitnessConnectView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI


struct FitnessConnectView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("러닝 데이터가 연동되지 않는 경우")
                    .font(FontStyle.button())
                
                Spacer()
            }
            
            Text(
                """
                건강 데이터 권한 설정이 되어있지 않으면
                데이터 연동이 되지 않을 수 있습니다.
                설정 → 개인정보 보호 및 보안
                → 건강 → Run Mile
                → 운동 읽기 허용
                """
            )
            .font(FontStyle.cellSubtitle())
            .multilineTextAlignment(.leading)
            
            TabView {
                Image(.health1)
                    .resizable()
                    .scaledToFit()
                Image(.health2)
                    .resizable()
                    .scaledToFit()
                Image(.health3)
                    .resizable()
                    .scaledToFit()
                Image(.health4)
                    .resizable()
                    .scaledToFit()
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
            
            Spacer()
        }
        .navigationTitle("Fitness 연동하기")
        .padding(.horizontal, 20)
    }
}

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
            
            Group {
                Text(
                """
                건강 데이터 권한 설정이 되어있지 않으면
                데이터 연동이 되지 않을 수 있습니다.
                설정 → 개인정보 보호 및 보안
                → 건강 → Run Mile
                → 운동 읽기 허용
                """
                )
                
//                Button("설정으로 이동"){
//                    if let url = URL(string: UIApplication.openSettingsURLString) {
//                        if UIApplication.shared.canOpenURL(url) {
//                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
//                        }
//                    }
//                }
            }
            .font(FontStyle.cellSubtitle())
            .multilineTextAlignment(.leading)
            
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 100)
                .foregroundStyle(.white)
            Spacer()
        }
        .navigationTitle("Fitness 연동하기")
        .padding(.horizontal, 20)
    }
}

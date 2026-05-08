//
//  FitnessConnectView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI


struct FitnessConnectView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // MARK: - Instruction Card
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(RunMileColor.primary)
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("러닝 데이터가 보이지 않나요?")
                                .font(.headline)
                                .foregroundStyle(RunMileColor.foreground)
                            
                            Text("건강 데이터 권한이 꺼져있으면 앱이 정상적으로 동작하지 않을 수 있습니다.")
                                .font(.subheadline)
                                .foregroundStyle(RunMileColor.mutedForeground)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Divider()
                    
                    // Steps
                    VStack(alignment: .leading, spacing: 12) {
                        StepRow(number: 1, text: "설정 앱을 열고 '개인정보 보호 및 보안'으로 이동")
                        StepRow(number: 2, text: "'건강' > 'Run Mile'을 선택")
                        StepRow(number: 3, text: "'모두 켜기' 또는 필요한 데이터 읽기 허용")
                    }
                    
                    
                }
                .padding(20)
                .runMileBrutalCard()
                
                
                // MARK: - Screenshots Carousel
                VStack(alignment: .leading, spacing: 12) {
                    Text("설정 가이드")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.foreground)
                        .padding(.horizontal, 4)
                    
                    TabView {
                        Group {
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
                        .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                        .padding(.bottom, 20)
                        .padding(.horizontal, 20)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 500)
                    .runMileBrutalCard()
                }
                
                Spacer()
            }
            .padding(20)
        }
        .background(RunMileColor.background)
        .navigationTitle("Fitness 연동하기")
        .navigationBarTitleDisplayMode(.inline)
    }
    
}


private struct StepRow: View {
    let number: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                .fill(RunMileColor.secondary)
                .frame(width: 24, height: 24)
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }
                .overlay {
                    Text("\(number)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.secondaryForeground)
                }
            
            Text(text)
                .font(.body)
                .foregroundStyle(RunMileColor.foreground)
        }
    }
}

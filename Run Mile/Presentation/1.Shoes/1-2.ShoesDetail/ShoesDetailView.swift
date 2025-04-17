//
//  ShoesDetailView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct ShoesDetailView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 170, height: 170)
                    .padding(.bottom, 10)
                
                Text("Adizero Boston 12ㄹㅇㄴㅁㄹ")
                    .font(FontStyle.shoeName())
                    .padding(.bottom, 40)
                
                ShoesMileageView()
                
                HStack {
                    Text("등록된 운동")
                        .font(FontStyle.kilometer())
                    
                    Spacer()
                }
                .padding(.bottom, 15)
                
                ForEach(0..<10) { _ in
                    WorkoutCell {
                        
                    }
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle("아디제롱")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                Button("수정") {
                    
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


private struct ShoesMileageView: View {
    var body: some View {
        Group {
            HStack {
                Text("현재 마일리지")
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("340km")
                    }
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.primary2)
                }
            }
            .padding(.bottom, 20)
            
            HStack {
                Text("목표 마일리지")
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("1000km")
                    }
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.primary2)
                }
            }
            .padding(.bottom, 40)
        }
        .font(FontStyle.kilometer())
    }
}


#Preview {
    ShoesDetailView()
}

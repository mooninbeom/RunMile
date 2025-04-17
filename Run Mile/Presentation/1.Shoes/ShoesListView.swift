//
//  ShoesListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct ShoesListView: View {
    var body: some View {
        VStack {
            HStack {
                Text("나의 신발장")
                    .font(FontStyle.hallOfFame())
                
                Spacer()
                
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary1)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(0..<10, id: \.self) { _ in
                        ShoesCell()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}



private struct ShoesCell: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 15)
            .frame(height: 200)
            .foregroundStyle(.workoutCell)
            .overlay {
                VStack {
                    HStack {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 165, height: 100)
                        
                        Spacer()
                        
                        ShoeInfoView()
                    }
                    
                    Spacer()
                    
                    MileageProgressView()
                }
                .padding(20)
            }
    }
}

private struct ShoeInfoView: View {
    var body: some View {
        VStack(spacing: 0) {
            Text("아디제로 보스턴 12")
                .font(FontStyle.shoeName())
                .padding(.bottom, 10)
                
            HStack(spacing: 0) {
                Text("250")
                    .font(FontStyle.cellDistance())
                    .foregroundStyle(.hallOfFame2)
                    .offset(y: -10)
                
                Rectangle()
                    .frame(width: 3, height: 65)
                    .rotationEffect(.degrees(30))
                
                Text("1000")
                    .font(FontStyle.cellDistance())
                    .offset(y: 10)
                
                Text("km")
                    .font(FontStyle.cellTitle())
                    .padding(.leading, 15)
                
            }
        }
    }
}

private struct MileageProgressView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 10)
                .foregroundStyle(.placeholder2)
            
            HStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 10)
                    .foregroundStyle(.hallOfFame2)
                
                Spacer(minLength: 100)
            }
        }
        .overlay(alignment: .trailing) {
            Image(systemName: "flag.fill")
                .font(.system(size: 24))
                .scaleEffect(x: -1)
                .foregroundStyle(.primary1)
                .offset(y: -16)
        }
    }
}


#Preview {
    ShoesListView()
}

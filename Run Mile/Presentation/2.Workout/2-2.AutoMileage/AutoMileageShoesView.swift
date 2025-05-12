//
//  AutoMileageShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 5/11/25.
//

import SwiftUI


struct AutoMileageShoesView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    Text("마일리지를 추가할 신발을 선택해주세요!")
                        .font(FontStyle.workoutSubtitle())
                        .padding(.bottom, 5)
                    
                    ForEach(0..<10, id: \.self) { i in
                        ChooseShoesCell(
                            shoes: .init(
                                id: .init(),
                                image: .init(),
                                shoesName: "테스트\(i)",
                                nickname: "테스트\(i)",
                                goalMileage: 1000,
                                currentMileage: 123,
                                workouts: []
                            )
                        ) {
                            
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            .navigationTitle("운동 자동 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소"){}
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("등록"){}
                }
            }
        }
    }
}



private struct ChooseShoesCell: View {
    let shoes: Shoes
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .frame(height: 70)
                .foregroundStyle(.workoutCell)
                .overlay {
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(shoes.nickname)
                                .font(FontStyle.shoeName())
                            Text("\(shoes.getCurrentMileage)/\(shoes.goalMileage.toInt)km")
                                .font(FontStyle.cellSubtitle())
                        }
                        
                        Spacer()
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 15)
                }
        }
    }
}

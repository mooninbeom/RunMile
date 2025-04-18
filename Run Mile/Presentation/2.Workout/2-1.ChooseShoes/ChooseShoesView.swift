//
//  ChooseShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct ChooseShoesView: View {
    @State private var viewModel: ChooseShoesViewModel = .init()
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SheetNavigationBar {
                viewModel.cancelButtonTapped()
            }
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            
            Text("마일리지를 추가할 신발을 선택해주세요!")
                .font(FontStyle.workoutSubtitle())
                .padding(.bottom, 20)
                .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(0..<1, id: \.self) { _ in
                        ChooseShoesCell{}
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}


private struct ChooseShoesCell: View {
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
                            Text("아디제로 보스턴 12")
                                .font(FontStyle.shoeName())
                            Text("123/1000km")
                                .font(FontStyle.cellSubtitle())
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 15)
                }
        }
    }
}


#Preview {
    ChooseShoesView()
}

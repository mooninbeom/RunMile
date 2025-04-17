//
//  AddShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct AddShoesView: View {
    @StateObject private var viewModel: AddShoesViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text("신발 추가")
                    .font(FontStyle.cellDistance())
                Spacer()
            }
            .overlay(alignment: .leading) {
                Button("취소") {
                    viewModel.cancelButtonTapped()
                }
            }
            .padding(.top, 20)
            
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.white)
                .frame(width: 170, height: 170)
                .padding(.vertical, 20)
            
            ShoeInfoTextField(category: .name, text: $viewModel.name)
                .padding(.vertical, 10)
            ShoeInfoTextField(category: .nickname, text: $viewModel.nickname)
                .padding(.vertical, 10)
            ShoeInfoTextField(category: .goalMileage, text: $viewModel.goalMileage)
                .padding(.vertical, 10)
            ShoeInfoTextField(category: .runMileage, text: $viewModel.runMileage)
                .padding(.vertical, 10)
            
            Spacer()

            CompleteButton {
                
            }
        }
        .padding(.horizontal, 20)
    }
}


private struct ShoeInfoTextField: View {
    let category: AddShoesViewModel.TextFieldCategory
    
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField(category.placeholder, text: $text)
                    .font(FontStyle.placeholder())
                
                Text("km")
                    .font(FontStyle.kilometer())
                    .opacity(
                        (category == .goalMileage || category == .runMileage) ? 1 : 0
                    )
            }
            .padding(.bottom, 5)
            
            Rectangle()
                .foregroundStyle(.primary2)
                .frame(height: 2)
            
            Text("신발의 기존 마일리지가 있는 경우 기입해주세요!")
                .font(FontStyle.miniPlaceholder())
                .foregroundStyle(.primary2)
                .opacity( category == .runMileage ? 1 : 0)
        }
    }
}


private struct CompleteButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.primary1)
                .frame(height: 50)
                .overlay {
                    Text("등록")
                        .font(FontStyle.button())
                        .foregroundStyle(.white)
                }
        }
    }
}


#Preview {
    AddShoesView()
}

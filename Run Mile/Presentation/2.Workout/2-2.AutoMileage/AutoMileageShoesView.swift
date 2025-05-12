//
//  AutoMileageShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 5/11/25.
//

import SwiftUI


struct AutoMileageShoesView: View {
    @State private var viewModel: AutoMileageShoesViewModel = .init(
        useCase: DefaultAddMileageShoesUseCase(
            shoesRepository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.shoes.isEmpty {
                    Text("자동 등록이 가능한 신발이 없습니다!")
                        .font(FontStyle.workoutSubtitle())
                        .padding(.bottom, 5)
                } else {
                    ShoesListScrollView(viewModel: $viewModel)
                }
            }
            .navigationTitle("운동 자동 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소"){
                        viewModel.cancelButtonTapped()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("저장"){
                        viewModel.saveButtonTapped()
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
                }
            }
        }
        .task {
            await viewModel.onAppear()
        }
    }
}


private struct ShoesListScrollView: View {
    @Binding var viewModel: AutoMileageShoesViewModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                Text("마일리지를 추가할 신발을 선택해주세요!")
                    .font(FontStyle.workoutSubtitle())
                    .padding(.bottom, 5)
                
                ForEach(viewModel.shoes) { shoes in
                    ChooseShoesCell(
                        viewModel: $viewModel,
                        shoes: shoes
                    )
                }
            }
            .padding(.horizontal, 20)
        }
    }
}



private struct ChooseShoesCell: View {
    @Binding var viewModel: AutoMileageShoesViewModel
    let shoes: Shoes
    
    var body: some View {
        Button {
            viewModel.shoesCellTapped(shoes: shoes)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundStyle(.workoutCell)
                
                RoundedRectangle(cornerRadius: 15)
                    .stroke(lineWidth: 1)
                    .foregroundStyle(.primary1)
                    .opacity(viewModel.selectedShoesId == shoes.id ? 1 : 0)
            }
            .frame(height: 70)
            .overlay {
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(shoes.nickname)
                            .font(FontStyle.shoeName())
                        Text("\(shoes.getCurrentMileage)/\(shoes.goalMileage.toInt)km")
                            .font(FontStyle.cellSubtitle())
                    }
                    .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "checkmark")
                        .foregroundStyle(.primary1)
                        .opacity(viewModel.selectedShoesId == shoes.id ? 1 : 0)
                }
                .padding(.horizontal, 15)
            }
        }
    }
}

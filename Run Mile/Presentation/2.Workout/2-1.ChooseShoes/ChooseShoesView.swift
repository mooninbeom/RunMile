//
//  ChooseShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct ChooseShoesView: View {
    @State private var viewModel: ChooseShoesViewModel
    
    let dismiss: () -> Void
    
    init(
        workouts: [RunningData],
        dismiss: @escaping () -> Void
    ) {
        self.viewModel = .init(
            useCase: DefaultChooseShoesUseCase(
                repository: ShoesDataRepositoryImpl()
            ),
            workouts: workouts
        )
        self.dismiss = dismiss
    }
    
    
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
                    ForEach(viewModel.shoes) { shoes in
                        ChooseShoesCell(shoes: shoes) {
                            viewModel.shoesCellTapped(shoes: shoes)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .task {
            await viewModel.onAppear()
        }
        .onDisappear {
            dismiss()
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
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 15)
                }
        }
    }
}

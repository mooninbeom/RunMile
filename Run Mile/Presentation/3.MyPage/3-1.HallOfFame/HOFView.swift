//
//  HOFView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI


struct HOFView: View {
    @State private var viewModel: HOFViewModel = .init(
        useCase: DefaultHOFUseCase(
            repository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                HStack {
                    Text("마일리지 목표를 달성한 신발을 보관합니다!")
                        .font(FontStyle.workoutSubtitle())
                    Spacer()
                }
                .padding(.bottom, 15)
                
                if viewModel.shoes.isEmpty {
                    Text("명예의 전당에 도달한 신발을 보관합니다.\n꾸준한 러닝으로 마일리지를 채워보세요!")
                        .font(FontStyle.shoeName())
                        .multilineTextAlignment(.center)
                        .padding(.top, 30)
                } else {
                    VStack(spacing: 15) {
                        ForEach(viewModel.shoes) { shoes in
                            ShoesCell(shoes: shoes)
                                .onTapGesture {
                                    viewModel.shoesCellTapped(shoes: shoes)
                                }
                        }
                    }
                }
            }
        }
        .navigationTitle("명예의 전당")
        .navigationBarTitleDisplayMode(.large)
        .padding(.horizontal, 20)
        .task {
            await viewModel.onAppear()
        }
    }
}

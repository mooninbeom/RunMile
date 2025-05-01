//
//  ShoesDetailView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct ShoesDetailView: View {
    @State private var viewModel: ShoesDetailViewModel
    
    init(shoes: Shoes) {
        self.viewModel = .init(
            useCase: DefaultShoesDetailUseCase(
                repository: ShoesDataRepositoryImpl()
            ),
            shoes: shoes
        )
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                
                if let uiImage = UIImage(data: viewModel.shoes.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)
                } else {
                    RoundedRectangle(cornerRadius: 15)
                        .frame(width: 170, height: 170)
                        .padding(.bottom, 10)
                }
                
                Text(viewModel.shoes.shoesName)
                    .font(FontStyle.shoeName())
                    .padding(.bottom, 40)
                
                ShoesMileageView(viewModel: viewModel)
                
                HStack {
                    Text("등록된 운동")
                        .font(FontStyle.kilometer())
                    
                    Spacer()
                }
                .padding(.bottom, 15)
                
                ForEach(viewModel.shoes.workouts) { workout in
                    WorkoutCell(workout: workout) {
                        
                    }
                    .padding(.bottom, 10)
                }
            }
            .navigationTitle(viewModel.shoes.nickname)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                switch viewModel.viewStatus {
                case .normal:
                    Button("수정", role: .none, action: viewModel.editButtonTapped)
                case .editing:
                    Button("취소", role: .cancel, action: viewModel.cancelButtonTapped)
                    Button("완료", role: .none, action: viewModel.completeButtonTapped)
                }

            }
            .padding(.horizontal, 20)
        }
        .animation(.easeInOut, value: viewModel.viewStatus)
    }
}


private struct ShoesMileageView: View {
    @Bindable var viewModel: ShoesDetailViewModel
    
    var body: some View {
        Group {
            HStack {
                Text("현재 마일리지")
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("\(Int(viewModel.shoes.currentMileage))km")
                    }
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.primary2)
                }
            }
            .padding(.bottom, 20)
            
            HStack(spacing: 0) {
                Text("목표 마일리지")
                
                VStack(spacing: 0) {
                    switch viewModel.viewStatus {
                    case .normal:
                        HStack {
                            Spacer()
                            Text("\(Int(viewModel.shoes.goalMileage))km")
                        }
                    case .editing:
                        HStack(spacing: 0) {
                            TextField("최대 1000", text: $viewModel.goalMileage)
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.numberPad)
                            Text("km")
                        }
                    }
                    
                    Rectangle()
                        .frame(height: 2)
                        .foregroundStyle(.primary2)
                }
            }
            .padding(.bottom, 40)
            .onChange(of: viewModel.goalMileage) {
                let text = viewModel.goalMileage
                if text.isEmpty { return }
                let isNumber = text.allSatisfy{ "0123456789".contains($0) }
                if isNumber {
                    let num = Int(text)!
                    if num > 1000 {
                        viewModel.goalMileage = "1000"
                    } else {
                        viewModel.goalMileage = "\(num)"
                    }
                } else {
                    viewModel.goalMileage.removeAll()
                }
            }
        }
        .font(FontStyle.kilometer())
    }
}

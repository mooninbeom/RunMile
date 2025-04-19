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
        self.viewModel = .init(shoes: shoes)
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
                
                ShoesMileageView(
                    currentMileage: viewModel.shoes.currentMileage,
                    goalMileage: viewModel.shoes.goalMileage
                )
                
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
                Button("수정") {
                    
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


private struct ShoesMileageView: View {
    let currentMileage: Double
    let goalMileage: Double
    
    var body: some View {
        Group {
            HStack {
                Text("현재 마일리지")
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("\(Int(currentMileage))km")
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
                        Text("\(Int(goalMileage))km")
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

//
//  HOFShoesDetailView.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import SwiftUI

struct HOFShoesDetailView: View {
    @State private var viewModel: HOFShoesDetailViewModel
    
    
    init(shoes: Shoes) {
        self.viewModel = .init(
            shoes: shoes
        )
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ShoesInformationView(viewModel: viewModel)
                
                HStack {
                    Text("등록된 운동")
                        .font(FontStyle.kilometer())
                    
                    Spacer()
                }
                .padding(.bottom, 15)
                
                if viewModel.shoes.workouts.isEmpty {
                    Text("등록된 운동이 없습니다.")
                        .font(FontStyle.shoeName())
                        .padding(.top, 20)
                } else {
                    ForEach(viewModel.shoes.workouts) { workout in
                        WorkoutCell(workout: workout) {}
                            .padding(.bottom, 10)
                    }
                }
            }
            .navigationTitle(viewModel.shoes.nickname)
            .navigationBarTitleDisplayMode(.large)
            .padding(.horizontal, 20)
        }
    }
}


private struct ShoesInformationView: View {
    let viewModel: HOFShoesDetailViewModel
    
    var body: some View {
        if let image = viewModel.shoes.image.toImage() {
            image
                .resizable()
                .scaledToFit()
                .frame(width: 170, height: 170)
                .onTapGesture {
                    viewModel.imageTapped()
                }
        } else {
            RoundedRectangle(cornerRadius: 15)
                .frame(width: 170, height: 170)
                .padding(.bottom, 10)
        }
        
        Text(viewModel.shoes.shoesName)
            .font(FontStyle.shoeName())
            .padding(.bottom, 10)
        
        ShoesMileageView(viewModel: viewModel)
    }
}


private struct ShoesMileageView: View {
    @Bindable var viewModel: HOFShoesDetailViewModel
    
    var body: some View {
        Group {
            HStack {
                Text("현재 마일리지")
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text(viewModel.shoes.getCurrentMileage + "km")
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
                    HStack {
                        Spacer()
                        Text("\(Int(viewModel.shoes.goalMileage))km")
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

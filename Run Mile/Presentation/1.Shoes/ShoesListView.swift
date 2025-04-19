//
//  ShoesListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct ShoesListView: View {
    @State private var viewModel: ShoesListViewModel = .init(
        useCase: DefaultShoesViewUseCase(
            repository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        VStack {
            HStack {
                Text("나의 신발장")
                    .font(FontStyle.hallOfFame())
                
                Spacer()
                
                Button {
                    viewModel.addShoesButtonTapped()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 24))
                        .foregroundStyle(.primary1)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView {
                VStack(spacing: 15) {
                    ForEach(viewModel.shoes) { shoes in
                        ShoesCell(shoes: shoes)
                            .onTapGesture {
                                NavigationCoordinator.shared
                                    .push(.shoesDetail, tab: .shoes)
                            }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}



private struct ShoesCell: View {
    let shoes: Shoes
    
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
                        
                        ShoeInfoView(shoes: shoes)
                    }
                    
                    Spacer(minLength: 50)
                    
                    MileageProgressView(
                        currentMileage: shoes.currentMileage,
                        goalMileage: shoes.goalMileage
                    )
                }
                .padding(20)
            }
    }
}

private struct ShoeInfoView: View {
    let shoes: Shoes
    
    var body: some View {
        VStack(spacing: 0) {
            Text(shoes.nickname)
                .font(FontStyle.shoeName())
                .padding(.bottom, 10)
                
            HStack(spacing: 0) {
                Text("\(Int(shoes.currentMileage))")
                    .font(FontStyle.cellDistance())
                    .foregroundStyle(.hallOfFame2)
                    .offset(y: -10)
                
                Rectangle()
                    .frame(width: 3, height: 65)
                    .rotationEffect(.degrees(30))
                
                Text("\(Int(shoes.goalMileage))")
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
    let currentMileage: Double
    let goalMileage: Double
    
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 10)
                    .foregroundStyle(.placeholder2)
                
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: proxy.size.width * (currentMileage / goalMileage), height: 10)
                    .foregroundStyle(.hallOfFame2)
                
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
}


#Preview {
    ShoesListView()
}

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
            
            if viewModel.shoes.isEmpty {
                Spacer()
                Text("신발장이 비어있습니다.\n새로운 신발을 추가해 주세요!")
                    .font(FontStyle.shoeName())
                    .multilineTextAlignment(.center)
                Spacer()
            } else {
                CurrentShoesListView(viewModel: $viewModel)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}


private struct CurrentShoesListView: View {
    @Binding var viewModel: ShoesListViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                ForEach(viewModel.shoes) { shoes in
                    ShoesCell(shoes: shoes)
                        .onTapGesture {
                            viewModel.shoesCellTapped(shoes)
                        }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}


private struct ShoesCell: View {
    let shoes: Shoes
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.workoutCell)
                .overlay {
                    HStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 15)
                            .frame(width: 120, height: 120)
                            .overlay {
                                if let image = shoes.image.toImage() {
                                    image
                                        .resizable()
                                        .scaledToFit()
                                }
                            }
                        
                        ShoeInfoView(shoes: shoes)
                        
                        Spacer()
                        
                    }
                    .padding(20)
                }
            
                RoundedRectangle(cornerRadius: 15)
                    .strokeBorder(lineWidth: 1)
                    .foregroundStyle(.primary1)
                    .opacity(shoes.isCurrentShoes ? 1 : 0)
        }
        .frame(height: 160)
    }
}

private struct ShoeInfoView: View {
    let shoes: Shoes
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(shoes.nickname)
                    .font(FontStyle.shoeName())
                    .padding(.leading, 10)
                    .padding(.top, 10)
                
                Spacer()
            }
            Spacer()
        }
        .overlay {
            HStack(spacing: 0) {
                Text(shoes.getCurrentMileage)
                    .foregroundStyle( shoes.isOverGoal ? .primary1 : .hallOfFame2 )
                
                Spacer()
                
                Text("km")
            }
            .font(FontStyle.cellTitle())
            .padding(.leading, 10)
        }
    }
}


// MARK: - Deprecated
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

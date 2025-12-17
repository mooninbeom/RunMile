//
//  AutoMileageShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 5/11/25.
//

import SwiftUI


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
        VStack(spacing: 0) {
            // Grabber
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            // Header
            VStack(spacing: 8) {
                Text("운동 자동 등록")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
                
                Text(viewModel.shoes.isEmpty ? "자동 등록할 신발이 없습니다." : "새로운 운동 기록이 추가되면 자동으로 등록됩니다.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.bottom, 24)
            
            if viewModel.shoes.isEmpty {
                Spacer()
                Text("등록 가능한 신발이 없습니다.")
                    .foregroundStyle(.secondary)
                Spacer()
            } else {
                // List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.shoes) { shoe in
                            ChooseShoesCell(
                                shoe: shoe,
                                isSelected: viewModel.selectedShoesId == shoe.id
                            )
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    viewModel.shoesCellTapped(shoes: shoe)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Bottom Action Button
            VStack {
                Button {
                    viewModel.saveButtonTapped()
                } label: {
                    Text("저장하기")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(viewModel.isSaveButtonDisabled ? Color(uiColor: .systemGray4) : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(viewModel.isSaveButtonDisabled)
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 10)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .task {
            await viewModel.onAppear()
        }
    }
}


private struct ChooseShoesCell: View {
    let shoe: Shoes
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .systemGray6))
                .frame(width: 60, height: 60)
                .overlay {
                    if let uiImage = UIImage(data: shoe.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    } else {
                        Image(systemName: "shoe.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(shoe.nickname)
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Text(shoe.shoesName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Selection Indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}

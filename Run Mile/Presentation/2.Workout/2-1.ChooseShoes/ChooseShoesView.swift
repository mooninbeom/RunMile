//
//  ChooseShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct ChooseShoesView: View {
    @State private var viewModel: ChooseShoesViewModel
    
    init(viewModel: ChooseShoesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Grabber
            Capsule()
                .fill(RunMileColor.mutedForeground.opacity(0.35))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 10)
            
            // Header
            VStack(spacing: 8) {
                Text("신발 선택")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.foreground)
                
                Text("\(viewModel.workoutCount)개의 운동 기록을 저장합니다.")
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(.bottom, 24)
            
            if viewModel.shoes.isEmpty {
                emptyStateView
            } else {
                // List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(viewModel.shoes) { shoe in
                            ChooseShoesCell(
                                shoe: shoe,
                                isSelected: viewModel.selectedShoe?.id == shoe.id
                            )
                            .onTapGesture {
                                withAnimation(.snappy) {
                                    viewModel.shoesCellTapped(shoe: shoe)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
            
            // Bottom Action Button
            if !viewModel.shoes.isEmpty {
                VStack {
                    Button {
                        viewModel.saveButtonTapped()
                    } label: {
                        Text("저장하기")
                            .runMilePrimaryButton(isEnabled: viewModel.selectedShoe != nil)
                    }
                    .disabled(viewModel.selectedShoe == nil)
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 10)
                }
            }
        }
        .background(RunMileColor.background)
        .task {
            await viewModel.onAppear()
        }
        .onDisappear {
            viewModel.sheetDidDisappear()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shoe.2")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(RunMileColor.mutedForeground)
            
            Text("신발장에서 운동을 등록할 신발을 먼저 추가해 주세요.")
                .font(.subheadline)
                .foregroundStyle(RunMileColor.mutedForeground)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
    }
}

#if DEBUG
#Preview {
    ChooseShoesView(
        viewModel: PreviewDIContainer().makeChooseShoesViewModel(
            workouts: Array(PreviewShoesMockData.workouts.prefix(2))
        )
    )
}
#endif


private struct ChooseShoesCell: View {
    let shoe: Shoes
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Image
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .fill(RunMileColor.muted)
                .frame(width: 60, height: 60)
                .overlay {
                    if let uiImage = UIImage(data: shoe.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                            .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                    } else {
                        Image(systemName: "shoe.fill")
                            .font(.title2)
                            .foregroundStyle(RunMileColor.mutedForeground)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
            
            // Text Info
            VStack(alignment: .leading, spacing: 4) {
                Text(shoe.nickname)
                    .font(.headline)
                    .foregroundStyle(RunMileColor.foreground)
                
                Text(shoe.shoesName)
                    .font(.caption)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Selection Indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(RunMileColor.accent)
                    .transition(.scale.combined(with: .opacity))
            } else {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
        }
        .padding(16)
        .runMileBrutalCard()
        .runMileSelectionBorder(isVisible: isSelected)
    }
}

//
//  AutoMileageShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 5/11/25.
//

import SwiftUI


struct AutoMileageShoesView: View {
    @State private var viewModel: AutoMileageShoesViewModel
    
    init(viewModel: AutoMileageShoesViewModel) {
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
                Text("운동 자동 등록")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.foreground)
                
                Text(viewModel.shoes.isEmpty ? "자동 등록할 신발이 없습니다." : "새로운 운동 기록이 추가되면 자동으로 등록됩니다.")
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
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
            if !viewModel.shoes.isEmpty {
                VStack {
                    Button {
                        viewModel.saveButtonTapped()
                    } label: {
                        Text("저장하기")
                            .runMilePrimaryButton(isEnabled: !viewModel.isSaveButtonDisabled)
                    }
                    .disabled(viewModel.isSaveButtonDisabled)
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
    }

    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shoe.2")
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(RunMileColor.mutedForeground)

            Text("신발장에서 자동 등록할 신발을 먼저 추가해 주세요.")
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
    AutoMileageShoesView(
        viewModel: PreviewDIContainer().makeAutoMileageShoesViewModel()
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
                    RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
                .overlay {
                    if let uiImage = UIImage(data: shoe.image) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                    } else {
                        Image(systemName: "shoe.fill")
                            .font(.title2)
                            .foregroundStyle(RunMileColor.mutedForeground)
                    }
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

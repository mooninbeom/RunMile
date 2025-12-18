//
//  HOFView.swift
//  Run Mile
//
//  Created by Antigravity on 12/18/25.
//

import SwiftUI

struct HOFView: View {
    @State private var viewModel: HOFViewModel = .init(
        useCase: DefaultHOFUseCase(
            repository: ShoesDataRepositoryImpl()
        )
    )
    
    
    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()
            
            // Header Background Gradient (Extending to Safe Area)
            GeometryReader { proxy in
                LinearGradient(
                    colors: [Color(uiColor: .systemBackground), Color(uiColor: .secondarySystemBackground)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 300 + proxy.safeAreaInsets.top)
                .ignoresSafeArea(edges: .top)
            }
            
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Header Section
                    headerView
                        .padding(.top, 10)
                    
                    // MARK: - Shoes List
                    if viewModel.shoes.isEmpty {
                        emptyStateView
                    } else {
                        LazyVStack(spacing: 16) {
                            ForEach(viewModel.shoes) { shoes in
                                Button {
                                    self.viewModel.shoesCellTapped(shoes: shoes)
                                } label: {
                                    HOFShoesCard(shoes: shoes)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await viewModel.onAppear()
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "laurel.leading")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)
                .padding(.bottom, 8)
            
            Text("LEGENDARY")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(.yellow)
                .tracking(2)
            
            Text("명예의 전당")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .foregroundStyle(.primary)
            
            Text("목표를 달성한 전설적인 신발들입니다.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .padding(.bottom, 10)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(height: 40)
            
            Image(systemName: "trophy")
                .font(.system(size: 80))
                .foregroundStyle(.secondary.opacity(0.3))
            
            Text("아직 전설이 된 신발이 없습니다.")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
            
            Text("꾸준한 러닝으로 마일리지를 채워\n명예의 전당에 이름을 올려보세요!")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding(40)
    }
}

// MARK: - Components

struct HOFShoesCard: View {
    let shoes: Shoes
    
    var body: some View {
        HStack(spacing: 16) {
            // Shoe Image
            if let uiImage = UIImage(data: shoes.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .tertiarySystemGroupedBackground))
                    .frame(width: 100, height: 100)
                    .overlay {
                        Image(systemName: "shoe.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(shoes.nickname)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Image(systemName: "laurel.leading")
                        .foregroundStyle(.yellow)
                }
                
                Text(shoes.shoesName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(Int(shoes.totalMileage))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text("km 달성")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 2)
                }
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
        .padding(12)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.yellow.opacity(0.3), lineWidth: 1)
        )
    }
}


#Preview("Empty") {
    HOFView()
}

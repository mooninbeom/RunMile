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
    
    // Status Logic for Mileage
    private var lifeSpanRatio: Double {
        guard viewModel.shoes.goalMileage > 0 else { return 0 }
        return min(viewModel.shoes.totalMileage / viewModel.shoes.goalMileage, 1.0)
    }
    
    private var statusColor: Color {
        switch lifeSpanRatio {
        case 0..<0.5: return RunMileColor.chart4
        case 0.5..<0.8: return RunMileColor.secondary
        default: return RunMileColor.primary
        }
    }

    private var statusForegroundColor: Color {
        lifeSpanRatio >= 0.5 && lifeSpanRatio < 0.8
        ? RunMileColor.secondaryForeground
        : RunMileColor.primaryForeground
    }
    
    // Brand Extraction
    private var shoeBrand: String {
        let components = viewModel.shoes.shoesName.split(separator: " ")
        return components.first.map(String.init) ?? "BRAND"
    }
    
    private var shoeModel: String {
        let components = viewModel.shoes.shoesName.split(separator: " ")
        if components.count > 1 {
            return components.dropFirst().joined(separator: " ")
        }
        return viewModel.shoes.shoesName
    }
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Hero Section
                headerView
                
                // MARK: - Mileage Section
                mileageCardView
                
                // MARK: - Workout History
                workoutHistoryList
            }
            .padding(.bottom, 40)
        }
        .background(RunMileColor.background)
        .navigationTitle(shoeModel) // Show Model Name
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Shoe Image
            if let uiImage = UIImage(data: viewModel.shoes.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                    .runMileBrutalCard(cornerRadius: RunMileRadius.image)
                    .onTapGesture {
                        viewModel.imageTapped()
                    }
            } else {
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(30)
                    .runMileBrutalCard(cornerRadius: RunMileRadius.image)
            }
            
            // Text Info
            VStack(spacing: 8) {
                Text(shoeBrand.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.primaryForeground)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                            .fill(RunMileColor.primary)
                    }
                
                Text(shoeModel)
                    .font(.title) // Larger title
                    .fontWeight(.heavy)
                    .foregroundStyle(RunMileColor.foreground)
                    .multilineTextAlignment(.center)
                
                Text("\"\(viewModel.shoes.nickname)\"")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                if viewModel.shoes.isGradutate {
                    Label("명예의 전당", systemImage: "laurel.leading")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.secondaryForeground)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background {
                            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                                .fill(RunMileColor.secondary)
                        }
                        .overlay {
                            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                        }
                        .padding(.top, 4)
                }
                
                // Hall of Fame Action Button (If eligible and not yet graduated)
                if !viewModel.shoes.isGradutate && viewModel.shoes.isOverGoal {
                    Button {
                        viewModel.HOFButtonTapped()
                    } label: {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("명예의 전당 입성")
                        }
                        .runMileSecondaryButton()
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }
    
    private var mileageCardView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label("마일리지 상태", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundStyle(RunMileColor.foreground)
                
                Spacer()
                
                Text("\(Int((1.0 - lifeSpanRatio) * 100))% 남음")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background {
                        RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                            .fill(statusColor)
                    }
                    .foregroundStyle(statusForegroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                    }
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                            .fill(RunMileColor.muted)
                            .frame(height: 12)
                        
                        RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                            .fill(statusColor)
                            .frame(width: geometry.size.width * max(lifeSpanRatio, 0.05), height: 12)
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text(viewModel.shoes.getCurrentMileage + "km")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(statusColor)
                    
                    Text("사용")
                        .font(.caption)
                        .foregroundStyle(RunMileColor.mutedForeground)
                        .padding(.leading, -4)
                    
                    Spacer()
                    
                    Text(viewModel.shoes.getGoalMileage + "km")
                        .font(.headline)
                        .foregroundStyle(RunMileColor.mutedForeground)
                    Text("목표")
                        .font(.caption)
                        .foregroundStyle(RunMileColor.mutedForeground)
                        .padding(.leading, -4)
                }
                .padding(.top, 4)
            }
            
            Divider()
            
            // Detailed Stats
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("주행 횟수")
                        .font(.caption)
                        .foregroundStyle(RunMileColor.mutedForeground)
                    Text("\(viewModel.shoes.workouts.count)회")
                        .font(.headline)
                        .foregroundStyle(RunMileColor.foreground)
                }
                
                VStack(alignment: .leading) {
                    Text("평균 거리")
                        .font(.caption)
                        .foregroundStyle(RunMileColor.mutedForeground)
                    
                    Text(viewModel.averageDistance)
                        .font(.headline)
                        .foregroundStyle(RunMileColor.foreground)
                }
            }
        }
        .padding(20)
        .runMileBrutalCard()
        .padding(.horizontal)
    }
    
    private var workoutHistoryList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("최근 활동")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(RunMileColor.foreground)
                .padding(.horizontal)
            
            if viewModel.shoes.workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(RunMileColor.foreground)
                    Text("아직 기록된 운동이 없습니다.")
                        .font(.subheadline)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                        .fill(RunMileColor.muted)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.shoes.workouts) { workout in
                        WorkoutHistoryCell(workout: workout, registeredShoeName: viewModel.shoes.shoesName)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

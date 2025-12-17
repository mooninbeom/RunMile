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
        case 0..<0.5: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
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
        .background(Color(uiColor: .systemGroupedBackground))
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
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: .black.opacity(0.15), radius: 15, x: 0, y: 10)
                    .onTapGesture {
                        viewModel.imageTapped()
                    }
            } else {
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .foregroundStyle(.secondary)
                    .padding(30)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            
            // Text Info
            VStack(spacing: 8) {
                Text(shoeBrand.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(uiColor: .secondarySystemBackground))
                    .clipShape(Capsule())
                
                Text(shoeModel)
                    .font(.title) // Larger title
                    .fontWeight(.heavy)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                
                Text("\"\(viewModel.shoes.nickname)\"")
                    .font(.body)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)
                
                if viewModel.shoes.isGradutate {
                    Label("명예의 전당", systemImage: "laurel.leading")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.yellow) // Or HOF Color
                        .clipShape(Capsule())
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
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .orange.opacity(0.3), radius: 8, x: 0, y: 4)
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
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text("\(Int((1.0 - lifeSpanRatio) * 100))% 남음")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.1))
                    .foregroundStyle(statusColor)
                    .clipShape(Capsule())
            }
            
            // Progress Bar
            VStack(spacing: 8) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(uiColor: .systemGray5))
                            .frame(height: 12)
                        
                        Capsule()
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
                        .foregroundStyle(.secondary)
                        .padding(.leading, -4)
                    
                    Spacer()
                    
                    Text(viewModel.shoes.getGoalMileage + "km")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    Text("목표")
                        .font(.caption)
                        .foregroundStyle(.secondary)
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
                        .foregroundStyle(.secondary)
                    Text("\(viewModel.shoes.workouts.count)회")
                        .font(.headline)
                }
                
                VStack(alignment: .leading) {
                    Text("평균 거리")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    // Logic adaptation needed if simple calculation:
                    // shoes.getCurrentMileage is String, parsing it or using local data:
                    let current = viewModel.shoes.totalMileage
                    let avg = viewModel.shoes.workouts.isEmpty ? 0 : current / Double(viewModel.shoes.workouts.count)
                    Text(String(format: "%.1fkm", avg))
                        .font(.headline)
                }
            }
        }
        .padding(20)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
    
    private var workoutHistoryList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("최근 활동")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            if viewModel.shoes.workouts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "figure.run.circle")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary.opacity(0.5))
                    Text("아직 기록된 운동이 없습니다.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(uiColor: .systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(viewModel.shoes.workouts) { workout in
                        WorkoutHistoryCell(workout: workout)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


// MARK: - Subcomponents
fileprivate struct WorkoutHistoryCell: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            // Date Box
            VStack {
                Text(workout.date, format: .dateTime.month(.abbreviated))
                    .font(.caption)
                    .foregroundStyle(.red)
                    .textCase(.uppercase)
                Text(workout.date, format: .dateTime.day())
                    .font(.title3)
                    .fontWeight(.bold)
            }
            .frame(width: 50)
            .padding(.vertical, 8)
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(workout.calculatedDistance) km")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    Label(workout.avgPace, systemImage: "stopwatch")
                    Label("\(Int(workout.time / 60))분", systemImage: "clock")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
    }
}


//
//  ShoesListView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI
import UserNotifications

struct ShoesListView: View {
    @State private var viewModel: ShoesListViewModel = .init(
        useCase: DefaultShoesViewUseCase(
            repository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    // 상단 요약 카드 (옵션)
                    semesterSummaryView
                    
                    // 신발 리스트 섹션 헤더
                    HStack {
                        Text("내 신발장")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Button(action: {
                            viewModel.addShoesButtonTapped()
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(RunMileColor.primary)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 카드 리스트
                    ForEach(viewModel.shoes) { shoe in
                        ShoeCardView(shoe: shoe)
                            .padding(.horizontal)
                            .onTapGesture {
                                viewModel.shoesCellTapped(shoe)
                            }
                    }
                    
                    if viewModel.shoes.isEmpty {
                        emptyStateView
                    }
                }
                .padding(.bottom, 20)
            }
            .background(RunMileColor.background)
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
    
    private var semesterSummaryView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("이번 주 달린 거리")
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                // TODO: 실제 주간 데이터 연동 필요
                Text("0.0 km")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(RunMileColor.foreground)
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "shoe.2")
                .font(.system(size: 40))
                .foregroundStyle(RunMileColor.foreground)
            Text("신발장이 비어있습니다.\n새로운 신발을 추가해 주세요!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .padding(.vertical, 28)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .fill(RunMileColor.muted)
        }
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .padding(.horizontal)
        .padding(.top, 40)
    }
}

// MARK: - Shoe Card View
struct ShoeCardView: View {
    let shoe: Shoes
    
    // 브랜드와 모델명 분리 로직 (가정: 첫 단어가 브랜드)
    private var shoeBrand: String {
        let components = shoe.shoesName.split(separator: " ")
        return components.first.map(String.init) ?? "BRAND"
    }
    
    private var shoeModel: String {
        let components = shoe.shoesName.split(separator: " ")
        if components.count > 1 {
            return components.dropFirst().joined(separator: " ")
        }
        return shoe.shoesName
    }
    
    // 수명 비율 계산
    private var lifeSpanRatio: Double {
        guard shoe.goalMileage > 0 else { return 0 }
        return min(shoe.totalMileage / shoe.goalMileage, 1.0)
    }
    
    // 상태 색상
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

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 신발 이미지 영역
            ZStack {
                RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                    .fill(RunMileColor.muted)
                    .frame(width: 80, height: 80)
                    .overlay {
                        RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                    }
                
                if let uiImage = UIImage(data: shoe.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                } else {
                    Image(systemName: "shoe.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
            }
            
            // 정보 영역
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(shoeBrand.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.mutedForeground)
                    
                    Spacer()
                    
                    // 남은 거리 퍼센트 뱃지
                    Text("\(Int((1.0 - lifeSpanRatio) * 100))% 남음")
                        .font(.caption2)
                        .fontWeight(.semibold)
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
                
                Text(shoeModel)
                    .font(.headline)
                    .foregroundStyle(RunMileColor.foreground)
                    .lineLimit(1)
                
                Text(shoe.nickname)
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                // 마일리지 프로그레스 바
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(shoe.totalMileage))km")
                            .fontWeight(.bold)
                            .foregroundStyle(RunMileColor.foreground)
                        Text("/ \(Int(shoe.goalMileage))km")
                            .foregroundStyle(RunMileColor.mutedForeground)
                        Spacer()
                    }
                    .font(.caption)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                                .frame(height: 6)
                                .foregroundStyle(RunMileColor.muted)
                            
                            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                                .frame(width: geometry.size.width * max(lifeSpanRatio, 0.05), height: 6)
                                .foregroundStyle(statusColor)
                        }
                    }
                    .frame(height: 6)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .runMileBrutalCard()
    }
}

#Preview {
    ShoesListView()
}

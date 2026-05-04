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
                                .foregroundStyle(Color.blue)
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
            .background(Color(uiColor: .secondarySystemBackground))
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
                    .foregroundStyle(.secondary)
                // TODO: 실제 주간 데이터 연동 필요
                Text("0.0 km")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
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
                .foregroundStyle(.secondary)
            Text("신발장이 비어있습니다.\n새로운 신발을 추가해 주세요!")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
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
        case 0..<0.5: return .green
        case 0.5..<0.8: return .orange
        default: return .red
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 신발 이미지 영역
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemGray6))
                    .frame(width: 80, height: 80)
                
                if let uiImage = UIImage(data: shoe.image) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "shoe.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40)
                        .foregroundStyle(.secondary)
                }
            }
            
            // 정보 영역
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(shoeBrand.uppercased())
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // 남은 거리 퍼센트 뱃지
                    Text("\(Int((1.0 - lifeSpanRatio) * 100))% 남음")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.1))
                        .foregroundStyle(statusColor)
                        .clipShape(Capsule())
                }
                
                Text(shoeModel)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                
                Text(shoe.nickname)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                // 마일리지 프로그레스 바
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("\(Int(shoe.totalMileage))km")
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        Text("/ \(Int(shoe.goalMileage))km")
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .font(.caption)
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .frame(height: 6)
                                .foregroundStyle(Color(uiColor: .systemGray5))
                            
                            Capsule()
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
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
    }
}

#Preview {
    ShoesListView()
}

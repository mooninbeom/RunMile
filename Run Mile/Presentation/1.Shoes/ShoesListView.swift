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
            repository: ShoesDataRepositoryImpl(),
            workoutRepository: WorkoutDataRepositoryImpl()
        )
    )
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 20) {
                    monthlySummaryView
                    
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
                    
                    ForEach(viewModel.shoeCardItems) { item in
                        ShoeCardView(item: item)
                            .padding(.horizontal)
                            .onTapGesture {
                                viewModel.shoesCellTapped(item.shoe)
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
    
    private var monthlySummaryView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("이번 달 달린 거리")
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Text(viewModel.monthlyDistanceText)
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

#Preview {
    ShoesListView()
}

//
//  MyPageView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct MyPageView: View {
    @State private var viewModel: MyPageViewModel = .init(
        useCase: DefaultMyPageUseCase()
    )
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // MARK: - Hall of Fame Hero Card
                Button {
                    viewModel.HOFButtonTapped()
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "trophy.fill")
                                    .foregroundStyle(.yellow)
                                Text("LEGENDARY")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.yellow)
                                    .tracking(1)
                            }
                            
                            Text("명예의 전당")
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundStyle(.white)
                            
                            Text("목표를 달성한 신발들을 확인해보세요")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 80))
                            .foregroundStyle(.white.opacity(0.1))
                            .rotationEffect(.degrees(-15))
                            .offset(x: 20)
                    }
                    .padding(24)
                    .background(
                        LinearGradient(colors: [Color(hex: "1C1C1E"), Color(hex: "2C2C2E")], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                }
                .buttonStyle(ScaleButtonStyle())
                
                // MARK: - Menu Grid
                VStack(spacing: 16) {
                    ForEach(MyPageViewModel.MyPageStatus.allCases, id: \.self) { status in
                        MenuCard(
                            icon: status.icon,
                            color: status.color,
                            title: status.cellName,
                            subtitle: status.subtitle,
                            action: {
                                viewModel.myPageCellTapped(status)
                            }
                        )
                    }
                }
            }
            .padding(20)
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .sheet(isPresented: $viewModel.isContactPresented) {
            ContactView()
        }
    }
}


// MARK: - Subviews

private struct MenuCard: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 16) {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                    .overlay {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundStyle(color)
                    }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(Color(uiColor: .systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.03), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Custom Button Style for Bouncy Effect
private struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.snappy(duration: 0.2), value: configuration.isPressed)
    }
}


#Preview {
    MyPageView()
}


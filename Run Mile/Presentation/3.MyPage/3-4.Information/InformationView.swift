//
//  InformationView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI


struct InformationView: View {
    let viewModel: InformationViewModel = .init()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // MARK: - Profile Section
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 160, height: 160)
                        
                        Image(.memoji)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 153, height: 153)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                    VStack(spacing: 8) {
                        Text("Mooni(문인범)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)
                        
                        Text("지구 최고의 iOS 개발자가 되기 위해\n노력중인 남자")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                }
                .padding(.top, 20)
                
                // MARK: - Contact Section
                VStack(spacing: 20) {
                    SectionHeader(title: "Connect")
                    
                    VStack(spacing: 0) {
                        // Email
                        Button {
                            viewModel.mailButtonTapped()
                        } label: {
                            ContactRow(icon: "envelope.fill", color: .white, title: "Email", value: "dlsqja567@naver.com")
                        }
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // GitHub
                        Link(destination: URL(string: "https://github.com/mooninbeom")!) {
                            ContactRow(icon: .github, title: "GitHub", value: "@mooninbeom")
                        }
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // LinkedIn
                        Link(destination: URL(string: "https://www.linkedin.com/in/인범-문-94ba63298")!) {
                            ContactRow(icon: .linkedIn, title: "LinkedIn", value: "@문인범")
                        }
                    }
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
                }
                
                // MARK: - App Info Section
                VStack(spacing: 8) {
                    Text("Run Mile")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(version)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("Copyright © 2025 Mooninbeom. All rights reserved.")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
            }
            .padding(20)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("개발자 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Helper Views

private struct SectionHeader: View {
    let title: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.leading, 8)
    }
}

private struct ContactRow: View {
    var icon: String? = nil
    var imageResource: ImageResource? = nil
    var color: Color = .primary
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                        .frame(width: 24)
                } else if let imageResource = imageResource {
                    Image(imageResource)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                }
            }
            .frame(width: 40) // Fixed width for alignment
            
            Text(title)
                .font(.body)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(16)
        .contentShape(Rectangle()) // For better tap area
    }
    
    init(icon: String, color: Color = .primary, title: String, value: String) {
        self.icon = icon
        self.color = color
        self.title = title
        self.value = value
    }
    
    init(icon: ImageResource, title: String, value: String) {
        self.imageResource = icon
        self.title = title
        self.value = value
    }
}

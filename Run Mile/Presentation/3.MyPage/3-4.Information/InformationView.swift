//
//  InformationView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI


struct InformationView: View {
    let viewModel: InformationViewModel
    
    init(viewModel: InformationViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // MARK: - Profile Section
                VStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                            .fill(RunMileColor.secondary)
                            .frame(width: 160, height: 160)
                            .overlay {
                                RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                            }
                            .shadow(color: RunMileColor.border, radius: 0, x: 4, y: 4)
                        
                        Image(.memoji)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 153, height: 153)
                            .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                    }
                    
                    VStack(spacing: 8) {
                        Text("Mooni(문인범)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(RunMileColor.foreground)
                        
                        Text("지구 최고의 iOS 개발자가 되기 위해\n노력중인 남자")
                            .font(.body)
                            .foregroundStyle(RunMileColor.mutedForeground)
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
                            ContactRow(icon: "envelope.fill", color: RunMileColor.accent, title: "Email", value: "dlsqja567@naver.com")
                        }
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // GitHub
                        Link(destination: URL(string: "https://github.com/mooninbeom")!) {
                            ContactRow(brandIcon: .github, title: "GitHub", value: "@mooninbeom")
                        }
                        
                        Divider()
                            .padding(.leading, 56)
                        
                        // LinkedIn
                        Link(destination: URL(string: "https://www.linkedin.com/in/인범-문-94ba63298")!) {
                            ContactRow(brandIcon: .linkedIn, title: "LinkedIn", value: "@문인범")
                        }
                    }
                    .runMileBrutalCard()
                }
                
                // MARK: - App Info Section
                VStack(spacing: 8) {
                    Text("Run Mile")
                        .font(.headline)
                        .foregroundStyle(RunMileColor.foreground)
                    
                    if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                        Text("Version \(version)")
                            .font(.caption)
                            .foregroundStyle(RunMileColor.mutedForeground)
                    }
                    
                    Text("Copyright © 2025 Mooninbeom. All rights reserved.")
                        .font(.caption2)
                        .foregroundStyle(RunMileColor.mutedForeground)
                        .padding(.top, 4)
                }
                .padding(.top, 20)
                .padding(.bottom, 40)
                
            }
            .padding(20)
        }
        .background(RunMileColor.background)
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
                .foregroundStyle(RunMileColor.mutedForeground)
                .textCase(.uppercase)
            Spacer()
        }
        .padding(.leading, 8)
    }
}

private struct ContactRow: View {
    var icon: String? = nil
    var brandIcon: BrandIcon? = nil
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
                        .frame(width: 24, height: 24)
                } else if let brandIcon {
                    brandIconView(brandIcon)
                }
            }
            .frame(width: 40, height: 40)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(RunMileColor.foreground)
                    .lineLimit(1)

                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .allowsTightening(true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Spacer(minLength: 8)

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(RunMileColor.mutedForeground)
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
    
    init(brandIcon: BrandIcon, title: String, value: String) {
        self.brandIcon = brandIcon
        self.title = title
        self.value = value
    }

    @ViewBuilder
    private func brandIconView(_ brandIcon: BrandIcon) -> some View {
        switch brandIcon {
        case .github:
            Image(.github)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)

        case .linkedIn:
            Text("in")
                .font(.system(size: 16, weight: .black))
                .foregroundStyle(RunMileColor.primaryForeground)
                .frame(width: 24, height: 24)
                .background(RunMileColor.accent)
                .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }
        }
    }
}

private enum BrandIcon {
    case github
    case linkedIn
}

#if DEBUG
#Preview {
    NavigationStack {
        InformationView(viewModel: PreviewDIContainer().makeInformationViewModel())
    }
}
#endif

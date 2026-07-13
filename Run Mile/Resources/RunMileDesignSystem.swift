//
//  RunMileDesignSystem.swift
//  Run Mile
//
//  Created by Codex on 5/5/26.
//

import SwiftUI

enum RunMileColor {
    static let primary = Color(hex: "FF3333")
    static let primaryForeground = Color.white
    static let secondary = Color(hex: "FFFF00")
    static let secondaryForeground = Color.black
    static let background = Color.white
    static let foreground = Color.black
    static let card = Color.white
    static let cardForeground = Color.black
    static let accent = Color(hex: "0066FF")
    static let accentForeground = Color.white
    static let muted = Color(hex: "F0F0F0")
    static let mutedForeground = Color(hex: "333333")
    static let border = Color.black
    static let input = Color.black
    static let ring = Color(hex: "FF3333")

    static let chart1 = Color(hex: "FF3333")
    static let chart2 = Color(hex: "FFFF00")
    static let chart3 = Color(hex: "0066FF")
    static let chart4 = Color(hex: "00CC00")
    static let chart5 = Color(hex: "CC00CC")

    static let power = Color(hex: "8A4B00")
    static let elevationUp = Color(hex: "FF8A00")

    static let success = chart4
    static let warning = chart2
    static let danger = primary
    static let selection = accent
    static let disabled = muted
    static let scrim = Color.black.opacity(0.24)
}

enum RunMileSpacing {
    static let xSmall: CGFloat = 4
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let regular: CGFloat = 16
    static let large: CGFloat = 20
    static let xLarge: CGFloat = 24
    static let screenHorizontal: CGFloat = 20
    static let section: CGFloat = 20
    static let sectionLarge: CGFloat = 40
}

enum RunMileRadius {
    static let none: CGFloat = 0
    static let small: CGFloat = 4
    static let card: CGFloat = 4
    static let input: CGFloat = 4
    static let button: CGFloat = 4
    static let image: CGFloat = 6
    static let progress: CGFloat = 2
    static let sheet: CGFloat = 28
}

enum RunMileSize {
    static let shoesCellHeight: CGFloat = 160
    static let shoesThumbnail: CGFloat = 120
    static let workoutCellHeight: CGFloat = 80
    static let myPageCellHeight: CGFloat = 70
    static let hallOfFameCellHeight: CGFloat = 115
    static let photoPicker: CGFloat = 170
    static let compactButtonHeight: CGFloat = 44
    static let primaryButtonHeight: CGFloat = 50
    static let hallOfFameButtonHeight: CGFloat = 60
    static let dividerHeight: CGFloat = 2
    static let progressHeight: CGFloat = 10
    static let iconSmall: CGFloat = 16
    static let iconMedium: CGFloat = 20
    static let iconLarge: CGFloat = 24
    static let photoIcon: CGFloat = 48
    static let trophyIcon: CGFloat = 40
    static let appUpdateSheetMaxHeight: CGFloat = 620
    static let appUpdateCardIcon: CGFloat = 52
    static let appUpdateCardSymbol: CGFloat = 24
    static let appUpdateSheetIcon: CGFloat = 64
    static let appUpdateSheetSymbol: CGFloat = 28
}

enum RunMileStroke {
    static let hairline: CGFloat = 1
    static let border: CGFloat = 2
    static let strong: CGFloat = 3
    static let selection: CGFloat = 2
}

enum RunMileTracking {
    static let kicker: CGFloat = 1.6
}

enum RunMileShadow {
    static let offset: CGFloat = 4
    static let compactOffset: CGFloat = 3
}

extension View {
    func runMileBrutalCard(
        cornerRadius: CGFloat = RunMileRadius.card,
        fill: Color = RunMileColor.card
    ) -> some View {
        background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(fill)
                .shadow(
                    color: RunMileColor.border,
                    radius: 0,
                    x: RunMileShadow.offset,
                    y: RunMileShadow.offset
                )
        }
            .foregroundStyle(RunMileColor.cardForeground)
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
    }

    func runMilePrimaryButton(isEnabled: Bool = true) -> some View {
        font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .frame(height: RunMileSize.primaryButtonHeight)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .fill(isEnabled ? RunMileColor.primary : RunMileColor.muted)
                    .shadow(
                        color: RunMileColor.border.opacity(isEnabled ? 1 : 0.35),
                        radius: 0,
                        x: RunMileShadow.offset,
                        y: RunMileShadow.offset
                    )
            }
            .foregroundStyle(isEnabled ? RunMileColor.primaryForeground : RunMileColor.mutedForeground)
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
    }

    func runMileSecondaryButton() -> some View {
        font(.headline)
            .fontWeight(.bold)
            .frame(maxWidth: .infinity)
            .frame(height: RunMileSize.primaryButtonHeight)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .fill(RunMileColor.secondary)
                    .shadow(
                        color: RunMileColor.border,
                        radius: 0,
                        x: RunMileShadow.offset,
                        y: RunMileShadow.offset
                    )
            }
            .foregroundStyle(RunMileColor.secondaryForeground)
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
    }

    func runMileSelectionBorder(isVisible: Bool = true) -> some View {
        overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                .strokeBorder(lineWidth: RunMileStroke.selection)
                .foregroundStyle(RunMileColor.selection)
                .opacity(isVisible ? 1 : 0)
        }
    }
}

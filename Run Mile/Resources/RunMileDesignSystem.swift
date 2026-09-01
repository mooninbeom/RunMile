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
    static let primaryText = Color(lightHex: "C61A2B", darkHex: "FF6666")
    static let primaryStrong = Color(hex: "C61A2B")
    static let secondary = Color(hex: "FFFF00")
    static let secondaryForeground = Color.black
    static let secondaryMutedForeground = Color(hex: "4A4A48")
    static let onMedia = Color.white
    static let mediaScrim = Color.black.opacity(0.8)
    static let fixedMediaSurface = Color.white
    static let fixedMediaBorder = Color.black
    static let background = Color(lightHex: "FFFFFF", darkHex: "101113")
    static let surface = Color(lightHex: "FFFFFF", darkHex: "1D1F22")
    static let surfaceElevated = Color(lightHex: "F7F7F5", darkHex: "282A2E")
    static let foreground = Color(lightHex: "101010", darkHex: "F6F4EF")
    static let muted = Color(lightHex: "F0F0F0", darkHex: "34373C")
    static let mutedForeground = Color(lightHex: "4A4A48", darkHex: "B9B9B4")
    static let border = Color(lightHex: "101010", darkHex: "F1EFE9")
    static let borderSubtle = Color(lightHex: "C6C6C2", darkHex: "5A5D62")
    static let hardShadow = Color(lightHex: "101010", darkHex: "030304")

    static let card = surface
    static let cardForeground = foreground
    static let sheetSurface = surface
    static let accent = Color(hex: "0066FF")
    static let accentForeground = Color.white
    static let selectionSurface = Color(lightHex: "EAF1FF", darkHex: "162C52")
    static let inputBorder = border
    static let input = inputBorder
    static let focusRing = primary
    static let ring = focusRing

    static let chart1 = Color(hex: "FF3333")
    static let chart2 = Color(lightHex: "887400", darkHex: "FFFF00")
    static let chart3 = Color(hex: "0066FF")
    static let chart4 = Color(lightHex: "00882D", darkHex: "31D66F")
    static let chart5 = Color(lightHex: "A600A6", darkHex: "E85CE8")
    static let chartGrid = Color(lightHex: "D5D5D2", darkHex: "464A50")
    static let chartAxis = mutedForeground

    static let power = Color(lightHex: "8A4B00", darkHex: "FFBE55")
    static let elevationUp = Color(lightHex: "B45309", darkHex: "FF9A3D")
    static let routeHalo = Color(lightHex: "101010", darkHex: "F1EFE9")
    static let mapOverlaySurface = Color(lightHex: "F2FFFFFF", darkHex: "E61D1F22")

    static let success = chart4
    static let warning = chart2
    static let danger = primaryStrong
    static let selection = accent
    static let disabled = muted
    static let disabledForeground = mutedForeground
    static let modalScrim = Color(lightHex: "3D000000", darkHex: "8A000000")
    static let loadingScrim = Color(lightHex: "33000000", darkHex: "73000000")
    static let mediaControlBackground = Color.black.opacity(0.6)
    static let scrim = modalScrim
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
                    color: RunMileColor.hardShadow,
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
                        color: RunMileColor.hardShadow.opacity(isEnabled ? 1 : 0.35),
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
                        color: RunMileColor.hardShadow,
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

    func runMileInputSurface(isFocused: Bool = false) -> some View {
        foregroundStyle(RunMileColor.foreground)
            .background {
                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                    .fill(RunMileColor.surfaceElevated)
            }
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                    .stroke(
                        isFocused ? RunMileColor.focusRing : RunMileColor.inputBorder,
                        lineWidth: RunMileStroke.border
                    )
            }
    }
}

//
//  HOFReportDataPreviewView.swift
//  Run Mile
//
//  Created by Codex on 5/13/26.
//

import SwiftUI


struct HOFReportDataPreviewView: View {
    private let report = HOFDataPreviewReport.sample

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                compactHero
                summaryBar
                careerReport
                memorableRuns
                mileageJourney
                usagePattern
                latePhaseChange
                previewActions
            }
            .padding(.vertical, 18)
        }
        .background(RunMileColor.background)
        .navigationTitle("졸업 데이터 리포트")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var compactHero: some View {
        HStack(alignment: .center, spacing: 16) {
            shoeSymbol

            VStack(alignment: .leading, spacing: 8) {
                Text("LEGENDARY REPORT")
                    .font(.caption2)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.primary)
                    .tracking(1.4)

                Text(report.nickname)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(report.model)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .lineLimit(2)

                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(report.totalDistance)
                        .font(.system(size: 34, weight: .black))
                        .foregroundStyle(RunMileColor.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    Text("목표 \(report.goalRate)")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.primary)
                }

                Text(report.activePeriod)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }

            Spacer(minLength: 0)
        }
        .padding(18)
        .runMileBrutalCard()
        .padding(.horizontal)
    }

    private var shoeSymbol: some View {
        ZStack {
            RunMileColor.secondary

            Image(systemName: "shoe.fill")
                .font(.system(size: 54, weight: .black))
                .foregroundStyle(RunMileColor.foreground)
                .rotationEffect(.degrees(-8))
        }
        .frame(width: 108, height: 108)
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .shadow(color: RunMileColor.border, radius: 0, x: 4, y: 4)
    }

    private var summaryBar: some View {
        HStack(spacing: 8) {
            HOFDataPreviewSummaryMetric(title: "거리", value: report.totalDistance)
            HOFDataPreviewSummaryMetric(title: "러닝", value: report.runCount)
            HOFDataPreviewSummaryMetric(title: "시간", value: report.totalTime)
        }
        .padding(.horizontal)
    }

    private var careerReport: some View {
        HOFDataPreviewSection(title: "커리어 리포트", icon: "chart.bar.fill") {
            LazyVGrid(columns: gridColumns, spacing: 10) {
                ForEach(report.careerMetrics) { metric in
                    HOFDataPreviewMetricCard(metric: metric)
                }
            }
        }
    }

    private var memorableRuns: some View {
        HOFDataPreviewSection(title: "대표 러닝", icon: "flag.checkered") {
            VStack(spacing: 10) {
                HOFDataPreviewRecordBoard(records: report.distanceRecords)
                
                ForEach(report.memorableRuns) { run in
                    HOFDataPreviewRunRow(run: run)
                }
            }
        }
    }

    private var mileageJourney: some View {
        HOFDataPreviewSection(title: "마일리지 여정", icon: "trophy.fill") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(report.milestones.enumerated()), id: \.element.id) { index, milestone in
                    HOFDataPreviewMilestoneRow(
                        milestone: milestone,
                        isLast: index == report.milestones.count - 1
                    )
                }
            }
        }
    }

    private var usagePattern: some View {
        HOFDataPreviewSection(title: "사용 패턴", icon: "scope") {
            VStack(spacing: 12) {
                HOFDataPreviewDistributionBar(items: report.distanceMix)

                VStack(alignment: .leading, spacing: 8) {
                    HOFDataPreviewInsightRow(icon: "moon.fill", text: "평일 저녁 러닝 비중이 가장 높았습니다.")
                    HOFDataPreviewInsightRow(icon: "figure.run", text: "5~8km 데일리 러닝에 가장 자주 사용됐습니다.")
                    HOFDataPreviewInsightRow(icon: "sparkles", text: "꾸준한 훈련용 신발로 사용된 패턴이 보입니다.")
                }
            }
        }
    }

    private var latePhaseChange: some View {
        HOFDataPreviewSection(title: "후반부 변화", icon: "arrow.triangle.2.circlepath") {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    HOFDataPreviewCompareCard(title: "첫 100km", value: "5'36\"", caption: "평균 페이스")
                    HOFDataPreviewCompareCard(title: "마지막 100km", value: "5'51\"", caption: "평균 페이스")
                }

                Text("후반부에는 장거리보다 짧은 러닝 비중이 늘었습니다. 신발 상태, 코스, 컨디션이 함께 영향을 줬을 가능성이 있어요.")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                    }
            }
        }
    }

    private var previewActions: some View {
        HOFDataPreviewSection(title: "다음 액션", icon: "square.and.arrow.up") {
            HStack(spacing: 10) {
                HOFDataPreviewActionButton(icon: "square.and.pencil", title: "메모")
                HOFDataPreviewActionButton(icon: "square.and.arrow.up", title: "공유 카드")
            }
        }
        .padding(.bottom, 20)
    }

    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }
}


private struct HOFDataPreviewSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)

            content
        }
        .padding(18)
        .runMileBrutalCard()
        .padding(.horizontal)
    }
}


private struct HOFDataPreviewSummaryMetric: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption2)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Text(value)
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.68)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .shadow(color: RunMileColor.border, radius: 0, x: 3, y: 3)
    }
}


private struct HOFDataPreviewMetricCard: View {
    let metric: HOFDataPreviewMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: metric.icon)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(metric.isHighlighted ? RunMileColor.secondaryForeground : RunMileColor.primaryForeground)
                .frame(width: 28, height: 28)
                .background(metric.isHighlighted ? RunMileColor.secondary : RunMileColor.primary, in: RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                }

            Text(metric.title)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Text(metric.value)
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
        }
    }
}


private struct HOFDataPreviewRecordBoard: View {
    let records: [HOFDataPreviewRecord]
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "rosette")
                    .font(.headline.weight(.black))
                
                Text("거리별 최고 기록")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)
                
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(records) { record in
                    HOFDataPreviewRecordTile(record: record)
                }
            }
            
            Text("해당 신발 최고 기록을 먼저 보여주고, 앱 전체 최고 기록이면 PB 배지를 붙입니다.")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


private struct HOFDataPreviewRecordTile: View {
    let record: HOFDataPreviewRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Text(record.title)
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(record.isAvailable ? RunMileColor.primary : RunMileColor.mutedForeground)

                Spacer(minLength: 4)

                if record.isPersonalBest {
                    Text("PB")
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.secondaryForeground)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(RunMileColor.secondary, in: RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                        }
                }
            }

            Text(record.time)
                .font(.title3)
                .fontWeight(.black)
                .foregroundStyle(record.isAvailable ? RunMileColor.foreground : RunMileColor.mutedForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

            Text(record.detail)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(12)
        .frame(minHeight: 106, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(record.isPersonalBest ? RunMileColor.secondary.opacity(0.22) : RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(record.isPersonalBest ? RunMileColor.primary : RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


private struct HOFDataPreviewRunRow: View {
    let run: HOFDataPreviewRun

    var body: some View {
        HStack(spacing: 12) {
            Text(run.badge)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(run.isKey ? RunMileColor.secondaryForeground : RunMileColor.primaryForeground)
                .frame(width: 44, height: 44)
                .background(run.isKey ? RunMileColor.secondary : RunMileColor.primary, in: RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(run.title)
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)

                Text(run.detail)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .padding(12)
        .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


private struct HOFDataPreviewMilestoneRow: View {
    let milestone: HOFDataPreviewMilestone
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(milestone.isGraduation ? RunMileColor.primary : RunMileColor.secondary)
                    .frame(width: 20, height: 20)
                    .overlay {
                        Circle()
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                    }

                if !isLast {
                    Rectangle()
                        .fill(RunMileColor.border)
                        .frame(width: 3, height: 34)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)

                Text(milestone.date)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(.bottom, isLast ? 0 : 16)

            Spacer()
        }
    }
}


private struct HOFDataPreviewDistributionBar: View {
    let items: [HOFDataPreviewDistribution]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                ForEach(items) { item in
                    Rectangle()
                        .fill(item.color)
                        .frame(maxWidth: .infinity)
                        .frame(height: 20)
                        .layoutPriority(item.ratio)
                        .overlay {
                            Rectangle()
                                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                        }
                }
            }

            ForEach(items) { item in
                HStack(spacing: 8) {
                    Rectangle()
                        .fill(item.color)
                        .frame(width: 14, height: 14)
                        .overlay {
                            Rectangle()
                                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                        }

                    Text(item.title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.foreground)

                    Spacer()

                    Text(item.percent)
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
            }
        }
    }
}


private struct HOFDataPreviewInsightRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.primary)
                .frame(width: 22)

            Text(text)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


private struct HOFDataPreviewCompareCard: View {
    let title: String
    let value: String
    let caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Text(value)
                .font(.title2)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)

            Text(caption)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


private struct HOFDataPreviewActionButton: View {
    let icon: String
    let title: String

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
        .font(.headline)
        .fontWeight(.black)
        .foregroundStyle(RunMileColor.foreground)
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .shadow(color: RunMileColor.border, radius: 0, x: 4, y: 4)
    }
}


private struct HOFDataPreviewReport {
    let nickname: String
    let model: String
    let totalDistance: String
    let goalRate: String
    let activePeriod: String
    let runCount: String
    let totalTime: String
    let careerMetrics: [HOFDataPreviewMetric]
    let distanceRecords: [HOFDataPreviewRecord]
    let memorableRuns: [HOFDataPreviewRun]
    let milestones: [HOFDataPreviewMilestone]
    let distanceMix: [HOFDataPreviewDistribution]

    static let sample = HOFDataPreviewReport(
        nickname: "첫 풀코스",
        model: "Adidas Adizero Adios Pro 3",
        totalDistance: "642.8km",
        goalRate: "107%",
        activePeriod: "2025.08.12 - 2026.02.03 · 176일",
        runCount: "83회",
        totalTime: "61h 24m",
        careerMetrics: [
            .init(title: "평균 거리", value: "7.7km", icon: "ruler", isHighlighted: true),
            .init(title: "평균 페이스", value: "5'42\"", icon: "stopwatch.fill", isHighlighted: false),
            .init(title: "최장 러닝", value: "21.1km", icon: "arrow.up.forward", isHighlighted: false),
            .init(title: "최고 페이스", value: "4'52\"", icon: "bolt.fill", isHighlighted: true),
            .init(title: "총 칼로리", value: "42,180kcal", icon: "flame.fill", isHighlighted: false),
            .init(title: "최다 사용 월", value: "2025.11", icon: "calendar", isHighlighted: false)
        ],
        distanceRecords: [
            .init(title: "5K", time: "24:18", detail: "2026.01.14 · 앱 전체 PB", isPersonalBest: true, isAvailable: true),
            .init(title: "10K", time: "52:04", detail: "2025.11.03 · 이 신발 최고", isPersonalBest: false, isAvailable: true),
            .init(title: "Half", time: "1:58:31", detail: "2025.12.21 · 앱 전체 PB", isPersonalBest: true, isAvailable: true),
            .init(title: "Full", time: "--", detail: "해당 거리 이상 기록 없음", isPersonalBest: false, isAvailable: false)
        ],
        memorableRuns: [
            .init(title: "첫 러닝", detail: "2025.08.12 · 5.2km · 5'58\"", badge: "1st", isKey: true),
            .init(title: "최장 러닝", detail: "2025.11.03 · 21.1km · 6'04\"", badge: "L", isKey: false),
            .init(title: "마지막 러닝", detail: "2026.02.03 · 7.4km · 5'47\"", badge: "END", isKey: false)
        ],
        milestones: [
            .init(title: "100km 달성", date: "2025.09.01", isGraduation: false),
            .init(title: "300km 달성", date: "2025.10.18", isGraduation: false),
            .init(title: "500km 달성", date: "2025.12.09", isGraduation: false),
            .init(title: "600km 목표 달성", date: "2026.01.22", isGraduation: false),
            .init(title: "졸업", date: "2026.02.03", isGraduation: true)
        ],
        distanceMix: [
            .init(title: "짧은 러닝 0-5km", percent: "18%", ratio: 0.18, color: RunMileColor.primary),
            .init(title: "데일리 러닝 5-8km", percent: "62%", ratio: 0.62, color: RunMileColor.secondary),
            .init(title: "장거리 10km+", percent: "20%", ratio: 0.20, color: RunMileColor.accent)
        ]
    )
}


private struct HOFDataPreviewMetric: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let icon: String
    let isHighlighted: Bool
}


private struct HOFDataPreviewRecord: Identifiable {
    let title: String
    let time: String
    let detail: String
    let isPersonalBest: Bool
    let isAvailable: Bool
    
    var id: String { title }
}


private struct HOFDataPreviewRun: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let badge: String
    let isKey: Bool
}


private struct HOFDataPreviewMilestone: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let isGraduation: Bool
}


private struct HOFDataPreviewDistribution: Identifiable {
    let id = UUID()
    let title: String
    let percent: String
    let ratio: Double
    let color: Color
}


#Preview("HOF Data Report Preview") {
    NavigationStack {
        HOFReportDataPreviewView()
    }
}

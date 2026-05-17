//
//  HOFShareCardVariantsPreviewView.swift
//  Run Mile
//
//  Created by Codex on 5/15/26.
//

import SwiftUI


struct HOFShareCardVariantsPreviewView: View {
    private let sample = HOFShareCardSample.sample

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                header

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 18) {
                        HOFShareCardFrame(title: "A. Poster") {
                            HOFPosterShareCard(sample: sample)
                        }

                        HOFShareCardFrame(title: "B. Split") {
                            HOFSplitShareCard(sample: sample)
                        }

                        HOFShareCardFrame(title: "C. Overlay") {
                            HOFOverlayShareCard(sample: sample)
                        }

                        HOFShareCardFrame(title: "D. Receipt") {
                            HOFReceiptShareCard(sample: sample)
                        }

                        HOFShareCardFrame(title: "E. Trophy") {
                            HOFTrophyShareCard(sample: sample)
                        }
                    }
                    .padding(.horizontal, RunMileSpacing.screenHorizontal)
                    .padding(.bottom, 8)
                }

                variantNotes
            }
            .padding(.vertical, 20)
        }
        .background(RunMileColor.background)
        .navigationTitle("HOF 공유 카드 시안")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("INSTAGRAM STORY")
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.primary)
                .tracking(1.8)

            Text("졸업 신발 공유 카드")
                .font(.largeTitle)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)

            Text("9:16 스토리 비율로 저장하거나 공유하기 좋은 방향의 시안입니다.")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
        }
        .padding(.horizontal, RunMileSpacing.screenHorizontal)
    }

    private var variantNotes: some View {
        VStack(alignment: .leading, spacing: 10) {
            HOFShareNote(title: "A Poster", description: "가장 대중적인 운동 앱 공유 카드 느낌. 큰 거리 수치와 신발 실루엣이 바로 보입니다.")
            HOFShareNote(title: "B Split", description: "블랙 기반이라 스토리 피드에서 강하게 튑니다. 성취감과 브랜드감이 가장 강한 안입니다.")
            HOFShareNote(title: "C Overlay", description: "사진/영상 위에 통계를 얹는 최신 공유 트렌드에 맞춘 안입니다. 나중에 사용자 사진과 결합하기 좋습니다.")
            HOFShareNote(title: "D Receipt", description: "기록 영수증처럼 데이터가 촘촘하게 보이는 안입니다. 재미는 있지만 감정성은 조금 낮습니다.")
            HOFShareNote(title: "E Trophy", description: "명예의 전당 콘셉트가 가장 직접적입니다. 졸업/달성의 기념비 느낌이 강합니다.")
        }
        .padding(18)
        .runMileBrutalCard()
        .padding(.horizontal)
    }
}


private struct HOFShareCardFrame<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 10) {
            content
                .frame(width: 246)
                .aspectRatio(9.0 / 16.0, contentMode: .fit)
                .clipShape(Rectangle())
                .overlay {
                    Rectangle()
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
                .shadow(color: RunMileColor.border, radius: 0, x: 5, y: 5)

            Text(title)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
        }
    }
}


private struct HOFPosterShareCard: View {
    let sample: HOFShareCardSample

    var body: some View {
        ZStack {
            RunMileColor.secondary

            VStack(alignment: .leading, spacing: 0) {
                HOFShareTopLabel(text: "LEGENDARY SHOE")

                Spacer()

                HOFShareShoeMark(size: 142, fill: RunMileColor.card)
                    .rotationEffect(.degrees(-8))
                    .padding(.bottom, 18)

                Text(sample.distance)
                    .font(.system(size: 48, weight: .black))
                    .foregroundStyle(RunMileColor.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Text(sample.nickname)
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)

                Text(sample.model)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .lineLimit(2)

                Spacer()

                HStack {
                    HOFShareSmallStat(title: "RUNS", value: sample.runs)
                    Spacer()
                    HOFShareSmallStat(title: "LONGEST", value: sample.longest)
                }
            }
            .padding(24)
        }
    }
}


private struct HOFSplitShareCard: View {
    let sample: HOFShareCardSample

    var body: some View {
        ZStack {
            RunMileColor.foreground

            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    Text("HALL OF FAME")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.secondary)
                        .tracking(1.4)

                    Spacer()

                    Text(sample.goalRate)
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.secondaryForeground)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(RunMileColor.secondary)
                }

                Spacer()

                Text(sample.distance)
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(RunMileColor.card)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                VStack(alignment: .leading, spacing: 8) {
                    HOFShareMetricStripe(title: "TOTAL RUNS", value: sample.runs)
                    HOFShareMetricStripe(title: "BEST PACE", value: sample.bestPace)
                    HOFShareMetricStripe(title: "ACTIVE DAYS", value: sample.activeDays)
                }

                Spacer()

                HOFShareShoeMark(size: 102, fill: RunMileColor.secondary)
                    .rotationEffect(.degrees(-12))

                Text(sample.nickname)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.card)
                    .lineLimit(1)
            }
            .padding(22)
        }
    }
}


private struct HOFOverlayShareCard: View {
    let sample: HOFShareCardSample

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    RunMileColor.accent,
                    RunMileColor.secondary,
                    RunMileColor.primary
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            VStack(spacing: 18) {
                Spacer()

                VStack(alignment: .leading, spacing: 12) {
                    Text("RUN MILE")
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.primary)
                        .tracking(1.4)

                    Text(sample.nickname)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.foreground)
                        .lineLimit(1)

                    Text(sample.distance)
                        .font(.system(size: 48, weight: .black))
                        .foregroundStyle(RunMileColor.foreground)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)

                    HStack(spacing: 10) {
                        HOFShareOverlayPill(title: "RUNS", value: sample.runs)
                        HOFShareOverlayPill(title: "PACE", value: sample.bestPace)
                    }
                }
                .padding(18)
                .background(.ultraThinMaterial)
                .overlay {
                    Rectangle()
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }

                Text("첫 풀코스를 함께 버틴 신발")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.card)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(RunMileColor.foreground)

                Spacer()
            }
            .padding(22)
        }
    }
}


private struct HOFReceiptShareCard: View {
    let sample: HOFShareCardSample

    var body: some View {
        ZStack {
            RunMileColor.card

            VStack(alignment: .leading, spacing: 16) {
                Text("GRADUATION REPORT")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.primary)
                    .tracking(1.4)

                Text(sample.nickname)
                    .font(.title)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)

                Rectangle()
                    .fill(RunMileColor.border)
                    .frame(height: 3)

                HOFShareReceiptRow(title: "TOTAL", value: sample.distance)
                HOFShareReceiptRow(title: "RUNS", value: sample.runs)
                HOFShareReceiptRow(title: "LONGEST", value: sample.longest)
                HOFShareReceiptRow(title: "BEST PACE", value: sample.bestPace)
                HOFShareReceiptRow(title: "GOAL", value: sample.goalRate)

                Spacer()

                HOFShareShoeMark(size: 94, fill: RunMileColor.secondary)
                    .rotationEffect(.degrees(-8))

                Text("THANKS FOR EVERY MILE")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .tracking(1)
            }
            .padding(24)
        }
    }
}


private struct HOFTrophyShareCard: View {
    let sample: HOFShareCardSample

    var body: some View {
        ZStack {
            RunMileColor.primary

            VStack(spacing: 18) {
                Image(systemName: "laurel.leading")
                    .font(.system(size: 72, weight: .black))
                    .foregroundStyle(RunMileColor.secondary)

                Text("LEGENDARY")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.secondaryForeground)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(RunMileColor.secondary)
                    .overlay {
                        Rectangle()
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                    }

                Spacer()

                Text(sample.distance)
                    .font(.system(size: 46, weight: .black))
                    .foregroundStyle(RunMileColor.primaryForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                Text(sample.nickname)
                    .font(.title2)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.primaryForeground)
                    .lineLimit(1)

                Text("\(sample.runs) · \(sample.activeDays)")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.secondary)

                Spacer()

                HOFShareShoeMark(size: 116, fill: RunMileColor.card)
                    .rotationEffect(.degrees(-10))
            }
            .padding(24)
        }
    }
}


private struct HOFShareTopLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.black)
            .foregroundStyle(RunMileColor.primaryForeground)
            .tracking(1.2)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RunMileColor.primary)
            .overlay {
                Rectangle()
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
    }
}


private struct HOFShareShoeMark: View {
    let size: CGFloat
    let fill: Color

    var body: some View {
        Image(systemName: "shoe.fill")
            .font(.system(size: size * 0.55, weight: .black))
            .foregroundStyle(RunMileColor.foreground)
            .frame(width: size, height: size)
            .background(fill)
            .overlay {
                Rectangle()
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
            .shadow(color: RunMileColor.border, radius: 0, x: 5, y: 5)
    }
}


private struct HOFShareSmallStat: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Text(value)
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
        }
    }
}


private struct HOFShareMetricStripe: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.caption2)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)

            Spacer()

            Text(value)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(RunMileColor.card)
        .overlay {
            Rectangle()
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
        }
    }
}


private struct HOFShareOverlayPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Text(value)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


private struct HOFShareReceiptRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Spacer()

            Text(value)
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }
}


private struct HOFShareNote: View {
    let title: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)

            Text(description)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}


private struct HOFShareCardSample {
    let nickname: String
    let model: String
    let distance: String
    let runs: String
    let longest: String
    let bestPace: String
    let goalRate: String
    let activeDays: String

    static let sample = HOFShareCardSample(
        nickname: "첫 풀코스",
        model: "Adidas Adizero Adios Pro 3",
        distance: "642.8KM",
        runs: "83 RUNS",
        longest: "21.1KM",
        bestPace: "4'52\"",
        goalRate: "107%",
        activeDays: "176 DAYS"
    )
}


#Preview("HOF Share Card Variants") {
    NavigationStack {
        HOFShareCardVariantsPreviewView()
    }
}

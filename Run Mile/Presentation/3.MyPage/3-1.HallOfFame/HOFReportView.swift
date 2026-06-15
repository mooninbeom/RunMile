//
//  HOFReportView.swift
//  Run Mile
//
//  Created by Codex on 5/13/26.
//

import SwiftUI


struct HOFReportView: View {
    @State private var viewModel: HOFReportViewModel

    init(viewModel: HOFReportViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                heroSection
                // 추후 기능 연결 예정
                // aiSummarySection
                careerSummarySection
                memorableRunsSection
                mileageJourneySection
                // graduationMemoSection
                // shareCardSection
            }
            .padding(.vertical, 20)
        }
        .background(RunMileColor.background)
        .navigationTitle("졸업 리포트")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            await viewModel.onAppear()
        }
    }

    private var heroSection: some View {
        VStack(spacing: 16) {
            shoeImage

            VStack(spacing: 8) {
                Text("LEGENDARY")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.primary)
                    .tracking(2)

                Text(viewModel.shoeNickname)
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundStyle(RunMileColor.foreground)
                    .multilineTextAlignment(.center)

                Text(viewModel.shoeName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 4) {
                Text(viewModel.report.totalMileageText)
                    .font(.system(size: 52, weight: .black))
                    .foregroundStyle(RunMileColor.foreground)
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)

                Text("목표 \(viewModel.goalMileageText)의 \(viewModel.report.achievementRate)%")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.primary)
            }

            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text(viewModel.report.dateRangeText)
            }
            .font(.caption)
            .fontWeight(.bold)
            .foregroundStyle(RunMileColor.mutedForeground)

            Text("\(viewModel.report.activeDays)일 함께 달림")
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.secondaryForeground)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(RunMileColor.secondary, in: RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .runMileBrutalCard()
        .padding(.horizontal)
    }

    private var shoeImage: some View {
        Group {
            if let uiImage = UIImage(data: viewModel.shoeImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .padding(18)
                    .onTapGesture(perform: viewModel.imageTapped)
            } else {
                Image(systemName: "shoe.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(RunMileColor.mutedForeground)
                    .padding(34)
            }
        }
        .frame(width: 170, height: 170)
        .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
        .shadow(color: RunMileColor.border, radius: 0, x: 5, y: 5)
    }

    private var aiSummarySection: some View {
        HOFReportSection(title: "AI 리포트", icon: "sparkles") {
            Text(viewModel.report.aiSummaryText)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.secondaryForeground)
                .fixedSize(horizontal: false, vertical: true)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(RunMileColor.secondary, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }
        }
    }

    private var careerSummarySection: some View {
        HOFReportSection(title: "커리어 요약", icon: "chart.bar.fill") {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 2), spacing: 10) {
                HOFReportStatTile(title: "총 거리", value: viewModel.report.totalMileageText)
                HOFReportStatTile(title: "러닝 횟수", value: viewModel.report.runCountText)
                HOFReportStatTile(title: "함께한 시간", value: viewModel.report.totalDurationText)
                HOFReportStatTile(title: "평균 거리", value: viewModel.report.averageDistanceText)
                HOFReportStatTile(title: "평균 페이스", value: viewModel.report.averagePaceText)
                HOFReportStatTile(title: "최장 러닝", value: viewModel.report.longestRunText)
            }
        }
    }

    private var memorableRunsSection: some View {
        HOFReportSection(title: "대표 러닝", icon: "flag.checkered") {
            VStack(spacing: 10) {
                HOFDistanceRecordsBoard(
                    records: viewModel.report.distanceRecords
                )
                
                ForEach(viewModel.report.memorableRuns) { run in
                    HOFMemorableRunRow(run: run)
                }
            }
        }
    }

    private var mileageJourneySection: some View {
        HOFReportSection(title: "마일리지 여정", icon: "point.topleft.down.curvedto.point.bottomright.up") {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(viewModel.report.milestones) { milestone in
                    HOFMileageMilestoneRow(milestone: milestone)
                }
            }
        }
    }

    private var graduationMemoSection: some View {
        HOFReportSection(title: "졸업 메모", icon: "square.and.pencil") {
            VStack(alignment: .leading, spacing: 10) {
                Text("이 신발과의 한 줄 메모")
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.primary)

                Text(viewModel.report.graduationMemoTitle)
                    .font(.title3)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)
                    .fixedSize(horizontal: false, vertical: true)

                Text("메모 편집 기능은 추후 연결 예정")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
            }
        }
    }

    private var shareCardSection: some View {
        HOFReportSection(title: "공유 카드", icon: "square.and.arrow.up") {
            VStack(spacing: 14) {
                VStack(spacing: 8) {
                    Text(viewModel.report.shareTitleText)
                        .font(.title2)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.foreground)

                    Text(viewModel.report.totalMileageText)
                        .font(.system(size: 44, weight: .black))
                        .foregroundStyle(RunMileColor.primary)

                    Text(viewModel.report.shareCaptionText)
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }

                ShareLink(item: viewModel.report.shareMessageText) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("공유 카드 만들기")
                    }
                    .runMileSecondaryButton()
                }
            }
        }
    }
}


#if DEBUG
#Preview("HOF Report") {
    NavigationStack {
        HOFReportView(
            viewModel: PreviewDIContainer().makeHOFReportViewModel(
                shoes: PreviewShoesMockData.hallOfFameShoes[0]
            )
        )
    }
}
#endif

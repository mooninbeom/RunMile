//
//  HOFReportViewModel.swift
//  Run Mile
//
//  Created by Codex on 5/14/26.
//

import Foundation


@Observable
final class HOFReportViewModel {
    private let shoes: Shoes
    private let useCase: HOFUseCase
    private var didLoadDistanceRecords = false
    
    let shoeImageData: Data
    let shoeName: String
    let shoeNickname: String
    let goalMileageText: String
    private(set) var report: HOFReportSummary
    
    init(shoes: Shoes, useCase: HOFUseCase) {
        self.shoes = shoes
        self.useCase = useCase
        self.shoeImageData = shoes.image
        self.shoeName = shoes.shoesName
        self.shoeNickname = shoes.nickname
        self.goalMileageText = "\(Int(shoes.goalMileage))km"
        self.report = HOFReportSummary(shoes: shoes)
    }
    
    /// 리포트 진입 시 세부 거리 샘플 기반 기록을 불러오고 앱 전체 PB 여부를 갱신합니다.
    func onAppear() async {
        guard await markDistanceRecordsLoadingIfNeeded() else { return }
        
        let shoeDistanceRecords = await useCase.fetchDistanceRecords(for: shoes.workouts)
        await updateReport(
            shoeDistanceRecords: shoeDistanceRecords,
            appDistanceRecords: []
        )
        
        do {
            let allRunningWorkouts = try await useCase.fetchAllRunningWorkouts()
            let appDistanceRecords = await useCase.fetchDistanceRecords(for: allRunningWorkouts)
            await updateReport(
                shoeDistanceRecords: shoeDistanceRecords,
                appDistanceRecords: appDistanceRecords
            )
        } catch {
            #if DEBUG
            print("[HOFReport] app-wide PB comparison skipped: \(error.localizedDescription)")
            #endif
        }
    }
    
    /// 거리 기록 로딩 중복 실행을 방지합니다.
    @MainActor
    private func markDistanceRecordsLoadingIfNeeded() -> Bool {
        guard !didLoadDistanceRecords else { return false }
        didLoadDistanceRecords = true
        return true
    }
    
    /// 신발 이미지를 자세히 볼 수 있는 이미지 상세 화면으로 이동합니다.
    @MainActor
    func imageTapped() {
        let currentTab = NavigationCoordinator.shared.tabStatus
        NavigationCoordinator.shared.push(.imageDetail(shoes.image), tab: currentTab)
    }
    
    /// 거리별 최고 기록 계산 결과를 화면 표시 모델에 반영합니다.
    @MainActor
    private func updateReport(
        shoeDistanceRecords: [WorkoutDistanceRecord],
        appDistanceRecords: [WorkoutDistanceRecord]
    ) {
        let loadedReport = HOFReportSummary(
            shoes: shoes,
            shoeDistanceRecords: shoeDistanceRecords,
            appDistanceRecords: appDistanceRecords,
            didLoadDistanceRecords: true
        )
        
        report = loadedReport
    }
}


struct HOFReportSummary {
    private let shoes: Shoes
    private let workouts: [Workout]
    private let bestShoeRecords: [WorkoutDistanceRecordTarget: WorkoutDistanceRecord]
    private let bestAppRecords: [WorkoutDistanceRecordTarget: WorkoutDistanceRecord]
    private let didLoadDistanceRecords: Bool
    
    init(
        shoes: Shoes,
        shoeDistanceRecords: [WorkoutDistanceRecord] = [],
        appDistanceRecords: [WorkoutDistanceRecord] = [],
        didLoadDistanceRecords: Bool = false
    ) {
        self.shoes = shoes
        self.workouts = Self.uniqueWorkouts(shoes.workouts).sorted { $0.date < $1.date }
        self.bestShoeRecords = Self.bestRecordsByTarget(shoeDistanceRecords)
        self.bestAppRecords = Self.bestRecordsByTarget(appDistanceRecords)
        self.didLoadDistanceRecords = didLoadDistanceRecords
    }
    
    private var totalWorkoutDistance: Double {
        workouts.reduce(0) { $0 + $1.distance }
    }
    
    private var totalDuration: Double {
        workouts.reduce(0) { $0 + $1.time }
    }
    
    var totalMileageText: String {
        String(format: "%.1fkm", shoes.totalMileage)
    }
    
    var achievementRate: Int {
        guard shoes.goalMileage > 0 else { return 0 }
        return Int((shoes.totalMileage / shoes.goalMileage * 100).rounded())
    }
    
    var activeDays: Int {
        guard let first = workouts.first?.date, let last = workouts.last?.date else { return 1 }
        let days = Calendar.current.dateComponents([.day], from: first, to: last).day ?? 0
        return max(days + 1, 1)
    }
    
    var dateRangeText: String {
        guard let first = workouts.first?.date, let last = workouts.last?.date else { return "기록 준비 중" }
        return "\(Self.dateFormatter.string(from: first)) - \(Self.dateFormatter.string(from: last))"
    }
    
    var totalDurationText: String {
        let hours = Int(totalDuration / 3600)
        let minutes = Int(totalDuration.truncatingRemainder(dividingBy: 3600) / 60)
        return hours > 0 ? "\(hours)시간 \(minutes)분" : "\(minutes)분"
    }
    
    var runCountText: String {
        "\(workouts.count)회"
    }
    
    var averageDistanceText: String {
        guard !workouts.isEmpty else { return "0.0km" }
        return String(format: "%.1fkm", (totalWorkoutDistance / 1000) / Double(workouts.count))
    }
    
    var averagePaceText: String {
        guard totalWorkoutDistance > 0 else { return "--" }
        return Self.paceText(secondsPerKilometer: totalDuration / (totalWorkoutDistance / 1000))
    }
    
    var longestRunText: String {
        guard let workout = workouts.max(by: { $0.distance < $1.distance }) else { return "--" }
        return String(format: "%.1fkm", workout.distance / 1000)
    }
    
    var aiSummaryText: String {
        "\(shoes.nickname)은 총 \(workouts.count)번의 러닝과 함께한 신발이에요. 목표 마일리지의 \(achievementRate)%를 달성했고, 평균 \(averageDistanceText) 러닝에 꾸준히 사용된 패턴이 보입니다."
    }
    
    var shareTitleText: String {
        "\(shoes.nickname) 졸업"
    }
    
    var shareCaptionText: String {
        "\(workouts.count) Runs · Longest \(longestRunText)"
    }
    
    var shareMessageText: String {
        "\(shareTitleText)\n총 \(totalMileageText)를 함께 달렸어요.\n\(shareCaptionText)"
    }
    
    var graduationMemoTitle: String {
        "첫 장거리 훈련을 함께 버텨준 신발"
    }
    
    var distanceRecords: [HOFDistanceRecord] {
        WorkoutDistanceRecordTarget.allCases.map { makeDistanceRecord(for: $0) }
    }
    
    var memorableRuns: [HOFMemorableRun] {
        var runs: [HOFMemorableRun] = []
        
        if let first = workouts.first {
            runs.append(makeRun(title: "첫 러닝", icon: "sparkles", workout: first, isPrimary: true))
        }
        
        if let longest = workouts.max(by: { $0.distance < $1.distance }) {
            runs.append(makeRun(title: "최장 러닝", icon: "arrow.up.forward", workout: longest, isPrimary: false))
        }
        
        if let last = workouts.last {
            runs.append(makeRun(title: "마지막 러닝", icon: "flag.checkered", workout: last, isPrimary: false))
        }
        
        return Array(runs.prefix(4))
    }
    
    var milestones: [HOFMileageMilestone] {
        guard shoes.goalMileage > 0 else {
            return [
                HOFMileageMilestone(
                    title: "졸업",
                    dateText: workouts.last.map { Self.dateFormatter.string(from: $0.date) } ?? "날짜 준비 중",
                    isGraduation: true
                )
            ]
        }
        
        let baseMilestones = [100, 300, 500].filter {
            Double($0) < shoes.goalMileage && Double($0) <= shoes.totalMileage
        }
        let goal = Int(shoes.goalMileage)
        let values = baseMilestones + [goal]
        
        var result = values.map { value in
            HOFMileageMilestone(
                title: "\(value)km 달성",
                dateText: estimatedDateText(for: Double(value)),
                isGraduation: false
            )
        }
        
        result.append(
            HOFMileageMilestone(
                title: "졸업",
                dateText: workouts.last.map { Self.dateFormatter.string(from: $0.date) } ?? "날짜 준비 중",
                isGraduation: true
            )
        )
        
        return result
    }
    
    private func makeRun(title: String, icon: String, workout: Workout, isPrimary: Bool) -> HOFMemorableRun {
        HOFMemorableRun(
            title: title,
            icon: icon,
            detail: "\(Self.dateFormatter.string(from: workout.date)) · \(String(format: "%.1fkm", workout.distance / 1000)) · \(workout.avgPace)",
            isPrimary: isPrimary
        )
    }
    
    private func estimatedDateText(for mileage: Double) -> String {
        guard !workouts.isEmpty else {
            return "날짜 준비 중"
        }
        
        if mileage <= shoes.currentMileage {
            return "등록 이전 기록"
        }
        
        var accumulatedMileage = shoes.currentMileage
        for workout in workouts {
            accumulatedMileage += workout.distance / 1000
            if accumulatedMileage >= mileage {
                return Self.dateFormatter.string(from: workout.date)
            }
        }
        
        return workouts.last.map { Self.dateFormatter.string(from: $0.date) } ?? "날짜 준비 중"
    }
    
    /// UseCase가 계산한 세부 스플릿 기록을 HOF 카드 표시 모델로 변환합니다.
    private func makeDistanceRecord(for target: WorkoutDistanceRecordTarget) -> HOFDistanceRecord {
        guard didLoadDistanceRecords else {
            return HOFDistanceRecord(
                title: target.title,
                timeText: "--",
                detailText: "기록 불러오는 중",
                workoutID: nil,
                isPersonalBest: false,
                isAvailable: false
            )
        }
        
        guard let shoeRecord = bestShoeRecords[target] else {
            return HOFDistanceRecord(
                title: target.title,
                timeText: "--",
                detailText: target.unavailableText,
                workoutID: nil,
                isPersonalBest: false,
                isAvailable: false
            )
        }
        
        let appBestRecord = bestAppRecords[target]
        let isPersonalBest = appBestRecord?.workoutID == shoeRecord.workoutID
        let recordScopeText = isPersonalBest ? "PB" : "이 신발 최고"
        let detailText = "\(Self.dateFormatter.string(from: shoeRecord.workoutDate)) · \(recordScopeText)"
        
        return HOFDistanceRecord(
            title: target.title,
            timeText: Self.recordDurationText(seconds: shoeRecord.duration),
            detailText: detailText,
            workoutID: shoeRecord.workoutID,
            isPersonalBest: isPersonalBest,
            isAvailable: true
        )
    }
    
    private static func paceText(secondsPerKilometer: Double) -> String {
        guard secondsPerKilometer.isFinite else { return "--" }
        let minutes = Int(secondsPerKilometer) / 60
        let seconds = Int(secondsPerKilometer) % 60
        return String(format: "%d'%02d\"", minutes, seconds)
    }
    
    private static func recordDurationText(seconds: TimeInterval) -> String {
        let totalSeconds = max(Int(seconds.rounded()), 0)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private static func uniqueWorkouts(_ workouts: [Workout]) -> [Workout] {
        var seenIds: Set<UUID> = []
        var result: [Workout] = []
        
        for workout in workouts where !seenIds.contains(workout.id) {
            seenIds.insert(workout.id)
            result.append(workout)
        }
        
        return result
    }
    
    /// 거리 타겟별 가장 빠른 기록을 미리 계산해 화면 갱신 시 반복 필터링을 줄입니다.
    private static func bestRecordsByTarget(_ records: [WorkoutDistanceRecord]) -> [WorkoutDistanceRecordTarget: WorkoutDistanceRecord] {
        var result: [WorkoutDistanceRecordTarget: WorkoutDistanceRecord] = [:]
        
        for record in records {
            if let current = result[record.target] {
                if record.duration < current.duration {
                    result[record.target] = record
                }
            } else {
                result[record.target] = record
            }
        }
        
        return result
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()
}


struct HOFDistanceRecord: Identifiable {
    let title: String
    let timeText: String
    let detailText: String
    let workoutID: UUID?
    let isPersonalBest: Bool
    let isAvailable: Bool
    
    var id: String { title }
}


struct HOFMemorableRun: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let detail: String
    let isPrimary: Bool
}


struct HOFMileageMilestone: Identifiable {
    let id = UUID()
    let title: String
    let dateText: String
    let isGraduation: Bool
}

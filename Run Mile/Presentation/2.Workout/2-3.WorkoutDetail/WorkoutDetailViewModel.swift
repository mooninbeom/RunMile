//
//  WorkoutDetailViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 12/26/25.
//

import CoreLocation
import HealthKit


@Observable
class WorkoutDetailViewModel {
    private let useCase: WorkoutDetailUseCase
    private let workout: Workout

    public var workoutDetail: WorkoutDetailData?
    public private(set) var altitudeSamples: [ChartSample] = []
    public private(set) var altitudeChartYScale: ClosedRange<Double> = 0...0
    public private(set) var analysisPaceSamples: [ChartSample] = []
    public private(set) var analysisMappedAltitudeSamples: [ChartSample] = []
    public private(set) var analysisPaceChartXScale: ClosedRange<Int> = 0...0
    public private(set) var analysisPaceChartYScale: ClosedRange<Double> = 0...0
    public private(set) var analysisXAxisValues: [Int] = []
    public private(set) var analysisAltitudeYAxisValues: [Double] = []
    public private(set) var analysisPaceYAxisValues: [Double] = []
    public private(set) var selectedAnalysis: WorkoutAnalysisSelection?

    public var showFullMap: Bool = false
    public var showMapAnalysis: Bool = false
    public var isSplitExpanded: Bool = false
    private var validAltitudeRoutes: [CLLocation] = []
    private var sortedRouteLocations: [CLLocation] = []
    private var sortedPacePoints: [UnifiedWorkoutDetailData] = []
    private var sortedHeartRatePoints: [UnifiedWorkoutDetailData] = []
    private var sortedPowerPoints: [UnifiedWorkoutDetailData] = []
    private var analysisTimeline: [WorkoutAnalysisPoint] = []

    private var _paceMinMaxValue: (Double, Double)?
    private var _heartMinMaxValue: (Double, Double)?
    private var _powerMinMaxValue: (Double, Double)?
    private var _verticalOscillationMinMaxValue: (Double, Double)?
    private var _groundContactTimeMinMaxValue: (Double, Double)?
    private var _strideLengthMinMaxValue: (Double, Double)?

    init(useCase: WorkoutDetailUseCase, workout: Workout) {
        self.useCase = useCase
        self.workout = workout
    }

    public var selectedSeconds: Int?
    public var selectedCategory: Set<ChartList> = [.pace]
    public var visibleCategory: Set<ChartList> = [.pace, .heart, .power]
    public func chartOpacity(for category: ChartList) -> Double {
        self.selectedCategory.contains(category) ? 1 : 0.3
    }
}


// MARK: - Actions
extension WorkoutDetailViewModel {
    /// 운동 상세 데이터를 불러오고, 지도 분석에 필요한 고도 캐시를 준비합니다.
    public func onAppear() async {
        do {
            let fetchedResult = try await useCase.fetchWorkoutDetailData(workout: self.workout, samplingCount: 80)
            self.workoutDetail = fetchedResult
            self.prepareAnalysisCaches(from: fetchedResult)
        } catch {
            await presentWorkoutDetailLoadFailureAlert(error: error)
        }
    }

    /// 분석 차트에서 선택된 시간에 가장 가까운 운동 샘플을 찾아 선택 상태를 갱신합니다.
    public func detailGraphTapped(seconds: Int) {
        let result = closestAnalysisPoint(at: seconds)
        let newSelectedSeconds = result?.seconds ?? seconds
        guard self.selectedSeconds != newSelectedSeconds else {
            return
        }

        self.selectedSeconds = newSelectedSeconds
        self.selectedAnalysis = result?.selection ?? makeAnalysisSelection(seconds: newSelectedSeconds)
    }

    /// 상세 그래프에서 표시할 metric 카테고리 선택 상태를 토글합니다.
    public func detailGraphButtonTapped(category: ChartList) {
        if self.selectedCategory.contains(category) {
            self.selectedCategory.remove(category)
        } else {
            self.selectedCategory.insert(category)
        }
    }

    /// 헤더 맵을 전체 화면 지도 모드로 전환합니다.
    public func headerMapTapped() {
        showFullMap = true
    }

    /// 전체 화면 지도를 닫고 지도 분석 선택 상태를 초기화합니다.
    public func fullMapCloseButtonTapped() {
        showFullMap = false
        closeMapAnalysis()
    }

    /// 지도 분석 패널을 표시합니다.
    public func mapAnalysisButtonTapped() {
        showMapAnalysis = true
    }

    /// 지도 분석 패널을 닫고 선택된 분석 지점을 초기화합니다.
    public func mapAnalysisCloseButtonTapped() {
        closeMapAnalysis()
    }

    /// 구간 기록 목록의 접힘/펼침 상태를 전환합니다.
    public func splitMoreButtonTapped() {
        isSplitExpanded.toggle()
    }

    /// 지도 분석 패널과 선택 지점 상태를 함께 초기화합니다.
    private func closeMapAnalysis() {
        showMapAnalysis = false
        selectedSeconds = nil
        selectedAnalysis = nil
    }

    /// 핵심 운동 상세 데이터 로딩 실패 시 안내 후 이전 화면으로 돌아갑니다.
    @MainActor
    private func presentWorkoutDetailLoadFailureAlert(error: Error) {
        let currentTab = NavigationCoordinator.shared.tabStatus
        NavigationCoordinator.shared.push(.init(
            title: "운동 상세를 불러오지 못했습니다.",
            message: "운동의 핵심 분석 데이터를 가져오는 중 문제가 발생했습니다.\n** \(error.localizedDescription)",
            firstButton: .cancel(title: "확인") {
                NavigationCoordinator.shared.popIfPossible(currentTab)
            },
            secondButton: nil
        ))
    }

    /// 지도 분석 차트에서 반복적으로 쓰는 고도 데이터와 축 범위를 미리 계산합니다.
    private func prepareAnalysisCaches(from detail: WorkoutDetailData) {
        let sortedRoutes = detail.routes
            .sorted { $0.timestamp < $1.timestamp }
        let validRoutes = detail.routes
            .filter { $0.verticalAccuracy >= 0 && $0.verticalAccuracy <= 20 && $0.altitude.isFinite }
            .sorted { $0.timestamp < $1.timestamp }

        self.sortedRouteLocations = sortedRoutes
        self.sortedPacePoints = detail.runningPace.sorted { $0.seconds < $1.seconds }
        self.sortedHeartRatePoints = detail.heartRate.sorted { $0.seconds < $1.seconds }
        self.sortedPowerPoints = detail.power.sorted { $0.seconds < $1.seconds }
        self.validAltitudeRoutes = validRoutes
        self.altitudeSamples = makeAltitudeSamples(from: validRoutes)
        self.altitudeChartYScale = makeAltitudeChartYScale(from: altitudeSamples)
        self.analysisPaceSamples = makeChartSamples(from: detail.runningPace)
        self.analysisPaceChartXScale = makeChartXScale(from: detail.runningPace)
        self.analysisPaceChartYScale = makeChartYScale(from: detail.runningPace)
        self.analysisMappedAltitudeSamples = makeMappedAnalysisAltitudeSamples(
            from: altitudeSamples,
            paceYScale: analysisPaceChartYScale,
            altitudeYScale: altitudeChartYScale
        )
        self.analysisXAxisValues = makeAnalysisXAxisValues(from: analysisPaceChartXScale)
        self.analysisAltitudeYAxisValues = makeAnalysisAltitudeYAxisValues(
            altitudeYScale: altitudeChartYScale,
            paceYScale: analysisPaceChartYScale
        )
        self.analysisPaceYAxisValues = makeAnalysisPaceYAxisValues(from: analysisPaceChartYScale)
        self.analysisTimeline = makeAnalysisTimeline()
    }
}


// MARK: - 요약 및 지도 섹션
extension WorkoutDetailViewModel {
    public var workoutStartDate: String {
        Self.koreanWorkoutDateFormatter.string(from: workout.date)
    }

    public var distance: String {
        workout.calculatedDistance
    }

    public var elapsedTime: String {
        workout.time.toHourMinuteSecondString()
    }

    public var calories: String {
        String(format: "%.0f", workout.activeEnergyBurned)
    }

    public var polylines: [CLLocationCoordinate2D] {
        guard let workoutDetail = workoutDetail else { return [] }
        return workoutDetail.routes.map { $0.coordinate }
    }

    public var routeSegments: [WorkoutRouteSegment] {
        workoutDetail?.routeSegments ?? []
    }

    public var routeStartCoordinate: CLLocationCoordinate2D? {
        routeEndpointLocations.first?.coordinate
    }

    public var routeEndCoordinate: CLLocationCoordinate2D? {
        routeEndpointLocations.last?.coordinate
    }

    private var routeEndpointLocations: [CLLocation] {
        if !sortedRouteLocations.isEmpty {
            return sortedRouteLocations
        }

        return workoutDetail?.routes.sorted { $0.timestamp < $1.timestamp } ?? []
    }

    public var routeFastestPace: String {
        guard let maxSpeed = workoutDetail?.runningPace.compactMap(\.value).max() else {
            return "-'--\""
        }

        return maxSpeed.meterPerSecondToPace()
    }

    public var routeSlowestPace: String {
        guard let minSpeed = workoutDetail?.runningPace.compactMap(\.value).min() else {
            return "-'--\""
        }

        return minSpeed.meterPerSecondToPace()
    }

    public var fastestRouteMarker: RoutePaceMarker? {
        guard let fastestPoint = fastestPacePoint,
              let route = closestRouteLocation(at: fastestPoint.seconds),
              let speed = fastestPoint.value else {
            return nil
        }

        return RoutePaceMarker(
            coordinate: route.coordinate,
            pace: speed.meterPerSecondToPace()
        )
    }

    public var selectedRouteMarker: RoutePaceMarker? {
        guard selectedSeconds != nil else { return nil }
        return selectedAnalysis?.marker
    }

    public var selectedElapsedTimeText: String {
        guard let selectedSeconds else {
            return "--:--"
        }

        return TimeInterval(selectedSeconds).toHourMinuteSecondString()
    }

    public var selectedPaceText: String {
        selectedAnalysis?.paceText ?? "-'--\""
    }

    public var selectedHeartRateText: String {
        selectedAnalysis?.heartRateText ?? "--"
    }

    public var selectedPowerText: String {
        guard let selectedSeconds,
              let point = closestWorkoutDetailPoint(in: sortedPowerPoints, at: selectedSeconds),
              let value = point.value else {
            return "--"
        }

        return String(format: "%.0f", value)
    }

    public var selectedAltitudeText: String {
        selectedAnalysis?.altitudeText ?? "--"
    }

    public var selectedAltitudeTrendSymbol: String? {
        selectedAnalysis?.altitudeTrendSymbol
    }

    public var visibleSplits: [SplitInfo] {
        isSplitExpanded ? splits : Array(splits.prefix(5))
    }

    public var shouldShowSplitMoreButton: Bool {
        splits.count > 5
    }

    public var splitMoreButtonTitle: String {
        isSplitExpanded ? "접기" : "더보기"
    }

    public var splitMoreButtonIcon: String {
        isSplitExpanded ? "chevron.up" : "chevron.down"
    }

    public var workoutTitle: String {
        let hour = Calendar.current.component(.hour, from: workout.date)

        var timeString = ""
        switch hour {
        case 4..<6: timeString = "새벽"
        case 6..<11: timeString = "아침"
        case 11..<14: timeString = "점심"
        case 14..<18: timeString = "오후"
        case 18..<21: timeString = "저녁"
        default: timeString = "밤"
        }

        return "\(timeString) 러닝"
    }
}


private extension WorkoutDetailViewModel {
    static let koreanWorkoutDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일 a h:mm"
        return formatter
    }()
}


// MARK: - Selected Route Analysis
extension WorkoutDetailViewModel {
    private var fastestPacePoint: UnifiedWorkoutDetailData? {
        sortedPacePoints
            .compactMap { point -> UnifiedWorkoutDetailData? in
                guard point.value != nil else {
                    return nil
                }

                return point
            }
            .max {
                ($0.value ?? 0) < ($1.value ?? 0)
            }
    }

    /// 운동 시작 이후 경과 시간에 가장 가까운 route location을 찾습니다.
    private func closestRouteLocation(at seconds: Int) -> CLLocation? {
        closestRouteLocation(in: sortedRouteLocations, at: seconds)
    }

    /// 특정 metric 배열에서 선택 시간과 가장 가까운 샘플을 이진 탐색으로 찾습니다.
    private func closestWorkoutDetailPoint(
        in points: [UnifiedWorkoutDetailData],
        at seconds: Int
    ) -> UnifiedWorkoutDetailData? {
        guard !points.isEmpty else {
            return nil
        }

        let nearestIndex = closestIndex(in: points, at: seconds) { $0.seconds }
        return points[nearestIndex]
    }

    /// 선택된 분석 시간에 표시할 마커, 페이스, 심박, 고도 정보를 하나로 구성합니다.
    private func makeAnalysisSelection(seconds: Int) -> WorkoutAnalysisSelection {
        let route = closestRouteLocation(at: seconds)
        let paceText = closestWorkoutDetailPoint(in: sortedPacePoints, at: seconds)?
            .value?
            .meterPerSecondToPace() ?? "-'--\""
        let heartRateText = closestWorkoutDetailPoint(in: sortedHeartRatePoints, at: seconds)?
            .value
            .map { String(format: "%.0f", $0) } ?? "--"

        return makeAnalysisSelection(
            seconds: seconds,
            route: route,
            paceText: paceText,
            heartRateText: heartRateText
        )
    }

    /// 이미 찾은 샘플들로 분석 선택 모델을 구성해 드래그 중 반복 탐색을 줄입니다.
    private func makeAnalysisSelection(
        seconds: Int,
        route: CLLocation?,
        paceText: String,
        heartRateText: String
    ) -> WorkoutAnalysisSelection {
        let altitudeText: String

        if let route,
           route.verticalAccuracy >= 0,
           route.verticalAccuracy <= 20,
           route.altitude.isFinite {
            altitudeText = String(format: "%.0f", route.altitude)
        } else {
            altitudeText = "--"
        }

        let marker = route.map {
            RoutePaceMarker(coordinate: $0.coordinate, pace: paceText)
        }

        return WorkoutAnalysisSelection(
            marker: marker,
            paceText: paceText,
            heartRateText: heartRateText,
            altitudeText: altitudeText,
            altitudeTrendSymbol: altitudeTrendSymbol(at: seconds)
        )
    }

    /// 차트 드래그 중 즉시 재사용할 분석 선택 타임라인을 생성합니다.
    private func makeAnalysisTimeline() -> [WorkoutAnalysisPoint] {
        sortedPacePoints.map { pacePoint in
            let seconds = pacePoint.seconds
            let route = closestRouteLocation(in: sortedRouteLocations, at: seconds)
            let paceText = pacePoint.value?.meterPerSecondToPace() ?? "-'--\""
            let heartRateText = closestWorkoutDetailPoint(in: sortedHeartRatePoints, at: seconds)?
                .value
                .map { String(format: "%.0f", $0) } ?? "--"
            let selection = makeAnalysisSelection(
                seconds: seconds,
                route: route,
                paceText: paceText,
                heartRateText: heartRateText
            )

            return WorkoutAnalysisPoint(seconds: seconds, selection: selection)
        }
    }

    /// 분석 타임라인에서 선택 시간과 가장 가까운 지점을 이진 탐색으로 찾습니다.
    private func closestAnalysisPoint(at seconds: Int) -> WorkoutAnalysisPoint? {
        guard !analysisTimeline.isEmpty else {
            return nil
        }

        let nearestIndex = closestIndex(in: analysisTimeline, at: seconds) { $0.seconds }
        return analysisTimeline[nearestIndex]
    }

    /// 운동 시작 이후 경과 시간에 가장 가까운 route location을 이진 탐색으로 찾습니다.
    private func closestRouteLocation(
        in routes: [CLLocation],
        at seconds: Int
    ) -> CLLocation? {
        guard !routes.isEmpty else {
            return nil
        }

        let targetDate = workout.workout.startDate.addingTimeInterval(TimeInterval(seconds))
        let nearestIndex = closestIndex(in: routes, at: targetDate) { $0.timestamp }
        return routes[nearestIndex]
    }

    /// 선택 지점 주변의 고도 변화율을 기반으로 오르막/내리막/평지 심볼을 결정합니다.
    private func altitudeTrendSymbol(at seconds: Int) -> String? {
        guard validAltitudeRoutes.count >= 3 else {
            return nil
        }

        let targetDate = workout.workout.startDate.addingTimeInterval(TimeInterval(seconds))
        let currentIndex = closestIndex(in: validAltitudeRoutes, at: targetDate) { $0.timestamp }

        let beforeIndex = nearbyRouteIndex(
            from: currentIndex,
            in: validAltitudeRoutes,
            direction: -1,
            minimumDistance: 25
        )
        let afterIndex = nearbyRouteIndex(
            from: currentIndex,
            in: validAltitudeRoutes,
            direction: 1,
            minimumDistance: 25
        )
        let distance = validAltitudeRoutes[beforeIndex].distance(from: validAltitudeRoutes[afterIndex])
        let altitudeDelta = validAltitudeRoutes[afterIndex].altitude - validAltitudeRoutes[beforeIndex].altitude

        guard distance >= 10 else {
            return "arrow.right"
        }

        let grade = altitudeDelta / distance
        let gradeThreshold = 0.004

        if grade > gradeThreshold {
            return "arrow.up.right"
        } else if grade < -gradeThreshold {
            return "arrow.down.right"
        } else {
            return "arrow.right"
        }
    }

    /// 현재 route index에서 지정 거리 이상 떨어진 주변 route index를 찾습니다.
    private func nearbyRouteIndex(
        from currentIndex: Array<CLLocation>.Index,
        in routes: [CLLocation],
        direction: Int,
        minimumDistance: CLLocationDistance
    ) -> Array<CLLocation>.Index {
        var index = currentIndex

        while routes.indices.contains(index + direction) {
            let nextIndex = index + direction
            let distance = routes[currentIndex].distance(from: routes[nextIndex])

            index = nextIndex

            if distance >= minimumDistance {
                break
            }
        }

        return index
    }

    /// 정렬된 Int key 배열에서 target에 가장 가까운 index를 반환합니다.
    private func closestIndex<T>(
        in items: [T],
        at target: Int,
        key: (T) -> Int
    ) -> Array<T>.Index {
        var lowerBound = items.startIndex
        var upperBound = items.endIndex

        while lowerBound < upperBound {
            let middleIndex = lowerBound + items.distance(from: lowerBound, to: upperBound) / 2

            if key(items[middleIndex]) < target {
                lowerBound = items.index(after: middleIndex)
            } else {
                upperBound = middleIndex
            }
        }

        guard lowerBound != items.startIndex else {
            return items.startIndex
        }

        guard lowerBound != items.endIndex else {
            return items.index(before: items.endIndex)
        }

        let previousIndex = items.index(before: lowerBound)
        let previousDistance = abs(key(items[previousIndex]) - target)
        let currentDistance = abs(key(items[lowerBound]) - target)

        return previousDistance <= currentDistance ? previousIndex : lowerBound
    }

    /// 정렬된 Date key 배열에서 target에 가장 가까운 index를 반환합니다.
    private func closestIndex<T>(
        in items: [T],
        at target: Date,
        key: (T) -> Date
    ) -> Array<T>.Index {
        var lowerBound = items.startIndex
        var upperBound = items.endIndex

        while lowerBound < upperBound {
            let middleIndex = lowerBound + items.distance(from: lowerBound, to: upperBound) / 2

            if key(items[middleIndex]) < target {
                lowerBound = items.index(after: middleIndex)
            } else {
                upperBound = middleIndex
            }
        }

        guard lowerBound != items.startIndex else {
            return items.startIndex
        }

        guard lowerBound != items.endIndex else {
            return items.index(before: items.endIndex)
        }

        let previousIndex = items.index(before: lowerBound)
        let previousDistance = abs(key(items[previousIndex]).timeIntervalSince(target))
        let currentDistance = abs(key(items[lowerBound]).timeIntervalSince(target))

        return previousDistance <= currentDistance ? previousIndex : lowerBound
    }

    /// route location의 고도를 분석 차트에서 사용할 샘플로 다운샘플링합니다.
    private func makeAltitudeSamples(from routes: [CLLocation]) -> [ChartSample] {
        guard !routes.isEmpty else {
            return []
        }

        let maxPointCount = 120
        let strideSize = max(1, routes.count / maxPointCount)

        return routes.enumerated().compactMap { index, route in
            guard index % strideSize == 0 || index == routes.index(before: routes.endIndex) else {
                return nil
            }

            return ChartSample(
                date: route.timestamp,
                seconds: Int(route.timestamp.timeIntervalSince(workout.workout.startDate)),
                rates: route.altitude,
                groupID: 0
            )
        }
    }

    /// 고도 차트의 실제 meter 축 범위를 계산합니다.
    private func makeAltitudeChartYScale(from samples: [ChartSample]) -> ClosedRange<Double> {
        let altitudes = samples.map(\.rates)

        guard let minValue = altitudes.min(),
              let maxValue = altitudes.max() else {
            return 0...0
        }

        guard minValue != maxValue else {
            return (minValue - 1)...(maxValue + 1)
        }

        return minValue...maxValue
    }
}


// MARK: - 스탯 요약 섹션
extension WorkoutDetailViewModel {
    public var avgHeartRate: String? {
        guard let workoutDetail = workoutDetail else { return nil }
        return formattedAverageMetricValue(from: workoutDetail.heartRate, format: "%.0f")
    }

    public var avgPace: String {
        self.workout.avgPace
    }

    public var avgPower: String? {
        guard let workoutDetail = workoutDetail else { return nil }
        return formattedAverageMetricValue(from: workoutDetail.power, format: "%.0f")
    }

    public var avgCadence: String? {
        guard let cadence = workoutDetail?.cadence,
              cadence.isFinite,
              cadence > 0 else { return nil }

        return String(format: "%.0f", cadence)
    }

    public var avgVerticalOscillation: String? {
        guard let workoutDetail = workoutDetail else { return nil }
        return formattedAverageMetricValue(from: workoutDetail.verticalOscillation, format: "%.1f")
    }

    public var avgGroundContactTime: String? {
        guard let workoutDetail = workoutDetail else { return nil }
        return formattedAverageMetricValue(from: workoutDetail.groundContactTime, format: "%.0f")
    }

    public var avgStrideLength: String? {
        guard let workoutDetail = workoutDetail else { return nil }
        return formattedAverageMetricValue(from: workoutDetail.strideLength, format: "%.1f")
    }

    public var elevationGain: String? {
        guard let routeData = workoutDetail?.routes,
              !routeData.isEmpty else { return nil }

        let elevationGain = routeData.calculateTotalElevationGain()
        return elevationGain.isEmpty ? nil : elevationGain
    }

    /// 선택 metric의 평균 표시값을 계산하고, 유효한 값이 없으면 카드를 숨길 수 있도록 nil을 반환합니다.
    private func formattedAverageMetricValue(from samples: [UnifiedWorkoutDetailData], format: String) -> String? {
        let values = samples
            .compactMap(\.value)
            .filter { $0.isFinite }

        guard !values.isEmpty else {
            return nil
        }

        let average = values.reduce(0, +) / Double(values.count)
        return String(format: format, average)
    }
}


// MARK: - 차트 생성 변수
extension WorkoutDetailViewModel {
    // MARK: - 심박수 섹션
    public var heartRateSamples: [ChartSample] {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.heartRate.isEmpty else {
            return []
        }
        var chartPoints: [ChartSample] = []
        var currentGroupID = 0
        var wasNil = false

        for sample in workoutDetail.heartRate {
            if let value = sample.value {
                if wasNil {
                    currentGroupID += 1
                    wasNil = false
                }

                chartPoints.append(.init(date: sample.date, seconds: sample.seconds, rates: value, groupID: currentGroupID))
            } else {
                wasNil = true
            }
        }

        return chartPoints
    }

    public var heartChartXScale: ClosedRange<Int> {
        let start = self.workoutDetail?.heartRate.first?.seconds ?? 0
        let end = self.workoutDetail?.heartRate.last?.seconds ?? 0
        return start...end
    }

    public var heartChartYScale: ClosedRange<Double> {
        guard let workoutDetail = workoutDetail else { return 0...0 }
        let result = workoutDetail.heartRate
            .compactMap { $0.value }
            .sorted()

        let bottom = result.first ?? 0
        let top = result.last ?? 0
        return bottom...top
    }

    public var heartMinMaxValue: (Double, Double)? {
        if let value = self._heartMinMaxValue { return value }

        guard let heart = self.workoutDetail?.heartRate.compactMap({ $0.value }) else {
            return nil
        }

        guard let min = heart.min(), let max = heart.max() else { return nil }

        self._heartMinMaxValue = (min, max)

        return self._heartMinMaxValue
    }

    // MARK: - 페이스 섹션
    public var paceSamples: [ChartSample] {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.runningPace.isEmpty else {
            return []
        }

        var chartPoints: [ChartSample] = []
        var currentGroupID = 0
        var wasNil = false

        for sample in workoutDetail.runningPace {
            if let value = sample.value {
                if wasNil {
                    currentGroupID += 1
                    wasNil = false
                }

                chartPoints.append(.init(date: sample.date, seconds: sample.seconds, rates: value, groupID: currentGroupID))
            } else {
                wasNil = true
            }
        }

        return chartPoints
    }

    public var paceChartXScale: ClosedRange<Int> {
        let start = self.workoutDetail?.runningPace.first?.seconds ?? 0
        let end = self.workoutDetail?.runningPace.last?.seconds ?? 0
        return start...end
    }

    public var paceChartYScale: ClosedRange<Double> {
        guard let workoutDetail = workoutDetail else { return 0...0 }
        let result = workoutDetail.runningPace
            .compactMap { $0.value }
            .sorted()

        let bottom = result.first ?? 0
        let top = result.last ?? 0
        return bottom...top
    }

    public var paceMinMaxValue: (Double, Double)? {
        if let value = self._paceMinMaxValue { return value }

        guard let pace = self.workoutDetail?.runningPace.compactMap({ $0.value }) else {
            return nil
        }

        guard let min = pace.min(), let max = pace.max() else { return nil }

        self._paceMinMaxValue = (min, max)

        return self._paceMinMaxValue
    }

    /// metric 샘플을 차트가 바로 그릴 수 있는 표시 샘플로 변환합니다.
    private func makeChartSamples(from samples: [UnifiedWorkoutDetailData]) -> [ChartSample] {
        guard !samples.isEmpty else {
            return []
        }

        var chartPoints: [ChartSample] = []
        var currentGroupID = 0
        var wasNil = false

        for sample in samples {
            if let value = sample.value {
                if wasNil {
                    currentGroupID += 1
                    wasNil = false
                }

                chartPoints.append(.init(date: sample.date, seconds: sample.seconds, rates: value, groupID: currentGroupID))
            } else {
                wasNil = true
            }
        }

        return chartPoints
    }

    /// metric 샘플의 x축 범위를 계산합니다.
    private func makeChartXScale(from samples: [UnifiedWorkoutDetailData]) -> ClosedRange<Int> {
        let start = samples.first?.seconds ?? 0
        let end = samples.last?.seconds ?? 0
        return start...end
    }

    /// metric 샘플의 y축 범위를 계산합니다.
    private func makeChartYScale(from samples: [UnifiedWorkoutDetailData]) -> ClosedRange<Double> {
        let values = samples.compactMap(\.value)

        guard let minValue = values.min(),
              let maxValue = values.max() else {
            return 0...0
        }

        return minValue...maxValue
    }

    /// 고도 샘플을 페이스 차트 좌표계에 맞춰 미리 변환합니다.
    private func makeMappedAnalysisAltitudeSamples(
        from samples: [ChartSample],
        paceYScale: ClosedRange<Double>,
        altitudeYScale: ClosedRange<Double>
    ) -> [ChartSample] {
        samples.map { sample in
            ChartSample(
                date: sample.date,
                seconds: sample.seconds,
                rates: mappedAnalysisAltitudeValue(
                    sample.rates,
                    paceYScale: paceYScale,
                    altitudeYScale: altitudeYScale
                ),
                groupID: sample.groupID
            )
        }
    }

    /// 분석 차트 x축에 표시할 경과 시간 tick 값을 시작/중간/끝 기준으로 생성합니다.
    private func makeAnalysisXAxisValues(from scale: ClosedRange<Int>) -> [Int] {
        let lowerBound = scale.lowerBound
        let upperBound = scale.upperBound
        let duration = upperBound - lowerBound

        guard duration > 0 else {
            return [lowerBound]
        }

        return [0, 1, 2, 3].map { index in
            lowerBound + Int((Double(duration) / 3) * Double(index))
        }
    }

    /// 분석 차트 왼쪽에 표시할 고도 y축 tick 값을 생성합니다.
    private func makeAnalysisAltitudeYAxisValues(
        altitudeYScale: ClosedRange<Double>,
        paceYScale: ClosedRange<Double>
    ) -> [Double] {
        guard altitudeYScale.lowerBound.isFinite,
              altitudeYScale.upperBound.isFinite,
              altitudeYScale.lowerBound != altitudeYScale.upperBound else {
            return []
        }

        return (0...3).map { index in
            let altitude = altitudeYScale.lowerBound + ((altitudeYScale.upperBound - altitudeYScale.lowerBound) / 3 * Double(index))
            return mappedAnalysisAltitudeValue(
                altitude,
                paceYScale: paceYScale,
                altitudeYScale: altitudeYScale
            )
        }
    }

    /// 분석 차트 오른쪽에 표시할 페이스 y축 tick 값을 생성합니다.
    private func makeAnalysisPaceYAxisValues(from scale: ClosedRange<Double>) -> [Double] {
        let minValue = scale.lowerBound
        let maxValue = scale.upperBound

        guard minValue.isFinite,
              maxValue.isFinite,
              minValue != maxValue else {
            return [minValue]
        }

        let step = (maxValue - minValue) / 4

        return (0...4).map { index in
            minValue + (step * Double(index))
        }
    }

    /// 고도 값을 페이스 차트의 y축 좌표계에 맞춰 표시용 값으로 변환합니다.
    public func mappedAnalysisAltitudeValue(_ altitude: Double) -> Double {
        mappedAnalysisAltitudeValue(
            altitude,
            paceYScale: analysisPaceChartYScale,
            altitudeYScale: altitudeChartYScale
        )
    }

    /// 고도 값을 주어진 페이스/고도 축 기준으로 변환합니다.
    private func mappedAnalysisAltitudeValue(
        _ altitude: Double,
        paceYScale: ClosedRange<Double>,
        altitudeYScale: ClosedRange<Double>
    ) -> Double {
        guard altitudeYScale.upperBound != altitudeYScale.lowerBound,
              paceYScale.upperBound != paceYScale.lowerBound else {
            return paceYScale.lowerBound
        }

        let ratio = (altitude - altitudeYScale.lowerBound) / (altitudeYScale.upperBound - altitudeYScale.lowerBound)
        return paceYScale.lowerBound + ((paceYScale.upperBound - paceYScale.lowerBound) * ratio)
    }

    /// 페이스 y축 좌표계로 변환된 고도 값을 실제 meter 라벨로 되돌립니다.
    public func analysisAltitudeLabel(for mappedValue: Double) -> String {
        guard analysisPaceChartYScale.upperBound != analysisPaceChartYScale.lowerBound else {
            return "--"
        }

        let ratio = (mappedValue - analysisPaceChartYScale.lowerBound) / (analysisPaceChartYScale.upperBound - analysisPaceChartYScale.lowerBound)
        let altitude = altitudeChartYScale.lowerBound + ((altitudeChartYScale.upperBound - altitudeChartYScale.lowerBound) * ratio)

        return String(format: "%.0fm", altitude)
    }

    /// 분석 차트 x축에 표시할 경과 시간을 H:MM 형태로 포맷합니다.
    public func analysisTimeLabel(seconds: Int) -> String {
        TimeInterval(seconds).toHourMinuteString()
    }

    // MARK: - 파워 섹션
    public var powerSamples: [ChartSample] {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.power.isEmpty else {
            return []
        }

        var chartPoints: [ChartSample] = []
        var currentGroupID = 0
        var wasNil = false

        for sample in workoutDetail.power {
            if let value = sample.value {
                if wasNil {
                    currentGroupID += 1
                    wasNil = false
                }

                chartPoints.append(.init(date: sample.date, seconds: sample.seconds, rates: value, groupID: currentGroupID))
            } else {
                wasNil = true
            }
        }

        return chartPoints
    }

    public var powerChartXScale: ClosedRange<Int> {
        let start = self.workoutDetail?.power.first?.seconds ?? 0
        let end = self.workoutDetail?.power.last?.seconds ?? 0
        return start...end
    }

    public var powerChartYScale: ClosedRange<Double> {
        guard let workoutDetail = workoutDetail else { return 0...0 }
        let result = workoutDetail.power
            .compactMap { $0.value }
            .sorted()

        let bottom = result.first ?? 0
        let top = result.last ?? 0
        return bottom...top
    }

    public var powerMinMaxValue: (Double, Double)? {
        guard self.visibleCategory.contains(.power) else { return nil }
        if let value = self._powerMinMaxValue { return value }

        guard let pace = self.workoutDetail?.power.compactMap({ $0.value }) else {
            return nil
        }

        guard let min = pace.min(), let max = pace.max() else { return nil }

        self._powerMinMaxValue = (min, max)

        return self._powerMinMaxValue
    }

    // MARK: - 수직 진폭 섹션
    public var verticalOscillationSamples: [ChartSample] {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.verticalOscillation.isEmpty else {
            return []
        }

        var chartPoints: [ChartSample] = []
        var currentGroupID = 0
        var wasNil = false

        for sample in workoutDetail.verticalOscillation {
            if let value = sample.value {
                if wasNil {
                    currentGroupID += 1
                    wasNil = false
                }

                chartPoints.append(.init(date: sample.date, seconds: sample.seconds, rates: value, groupID: currentGroupID))
            } else {
                wasNil = true
            }
        }

        return chartPoints
    }

    public var verticalOscillationChartXScale: ClosedRange<Int> {
        let start = self.workoutDetail?.verticalOscillation.first?.seconds ?? 0
        let end = self.workoutDetail?.verticalOscillation.last?.seconds ?? 0
        return start...end
    }

    public var verticalOscillationChartYScale: ClosedRange<Double> {
        guard let workoutDetail = workoutDetail else { return 0...0 }
        let result = workoutDetail.verticalOscillation
            .compactMap { $0.value }
            .sorted()

        let bottom = result.first ?? 0
        let top = result.last ?? 0
        return bottom...top
    }

    public var verticalOscillationMinMaxValue: (Double, Double)? {
        guard self.visibleCategory.contains(.verticalOscillation) else { return nil }
        if let value = self._verticalOscillationMinMaxValue { return value }

        guard let pace = self.workoutDetail?.verticalOscillation.compactMap({ $0.value }) else {
            return nil
        }

        guard let min = pace.min(), let max = pace.max() else { return nil }

        self._verticalOscillationMinMaxValue = (min, max)

        return self._verticalOscillationMinMaxValue
    }

}


// MARK: - 나머지
extension WorkoutDetailViewModel {
    public var splits: [SplitInfo] {
        self.workoutDetail?.splits ?? []
    }
}


struct ChartSample: Identifiable {
    let date: Date
    let seconds: Int
    let rates: Double
    let groupID: Int

    var id: String {
        "\(groupID)-\(seconds)-\(date.timeIntervalSinceReferenceDate)"
    }
}


struct RoutePaceMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let pace: String
}


struct WorkoutAnalysisSelection {
    let marker: RoutePaceMarker?
    let paceText: String
    let heartRateText: String
    let altitudeText: String
    let altitudeTrendSymbol: String?
}


private struct WorkoutAnalysisPoint {
    let seconds: Int
    let selection: WorkoutAnalysisSelection
}


extension WorkoutRouteSegment {
    var centerCoordinate: CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else {
            return nil
        }

        return coordinates[coordinates.count / 2]
    }
}

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
    public private(set) var selectedAnalysis: WorkoutAnalysisSelection?
    
    public var showFullMap: Bool = false
    public var showMapAnalysis: Bool = false
    public var isSplitExpanded: Bool = false
    private var validAltitudeRoutes: [CLLocation] = []
    
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
            print(error)
        }
    }
    
    /// 분석 차트에서 선택된 시간에 가장 가까운 운동 샘플을 찾아 선택 상태를 갱신합니다.
    public func detailGraphTapped(seconds: Int){
        let result = workoutDetail?.runningPace.min {
            let dis1 = abs(seconds - $0.seconds)
            let dis2 = abs(seconds - $1.seconds)
            return dis1 < dis2
        }
        
        let newSelectedSeconds = result?.seconds ?? seconds
        guard self.selectedSeconds != newSelectedSeconds else {
            return
        }
        
        self.selectedSeconds = newSelectedSeconds
        self.selectedAnalysis = makeAnalysisSelection(seconds: newSelectedSeconds)
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
    
    /// 지도 분석 차트에서 반복적으로 쓰는 고도 데이터와 축 범위를 미리 계산합니다.
    private func prepareAnalysisCaches(from detail: WorkoutDetailData) {
        let validRoutes = detail.routes
            .filter { $0.verticalAccuracy >= 0 && $0.verticalAccuracy <= 20 && $0.altitude.isFinite }
            .sorted { $0.timestamp < $1.timestamp }
        
        self.validAltitudeRoutes = validRoutes
        self.altitudeSamples = makeAltitudeSamples(from: validRoutes)
        self.altitudeChartYScale = makeAltitudeChartYScale(from: altitudeSamples)
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
              let point = closestWorkoutDetailPoint(in: workoutDetail?.power, at: selectedSeconds),
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
        workoutDetail?.runningPace
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
        guard let routes = workoutDetail?.routes,
              !routes.isEmpty else {
            return nil
        }
        
        let targetDate = workout.workout.startDate.addingTimeInterval(TimeInterval(seconds))
        
        return routes.min {
            abs($0.timestamp.timeIntervalSince(targetDate)) < abs($1.timestamp.timeIntervalSince(targetDate))
        }
    }
    
    /// 특정 metric 배열에서 선택 시간과 가장 가까운 샘플을 찾습니다.
    private func closestWorkoutDetailPoint(
        in points: [UnifiedWorkoutDetailData]?,
        at seconds: Int
    ) -> UnifiedWorkoutDetailData? {
        points?.min {
            abs($0.seconds - seconds) < abs($1.seconds - seconds)
        }
    }
    
    /// 선택된 분석 시간에 표시할 마커, 페이스, 심박, 고도 정보를 하나로 구성합니다.
    private func makeAnalysisSelection(seconds: Int) -> WorkoutAnalysisSelection {
        let route = closestRouteLocation(at: seconds)
        let paceText = closestWorkoutDetailPoint(in: workoutDetail?.runningPace, at: seconds)?
            .value?
            .meterPerSecondToPace() ?? "-'--\""
        let heartRateText = closestWorkoutDetailPoint(in: workoutDetail?.heartRate, at: seconds)?
            .value
            .map { String(format: "%.0f", $0) } ?? "--"
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
    
    /// 선택 지점 주변의 고도 변화율을 기반으로 오르막/내리막/평지 심볼을 결정합니다.
    private func altitudeTrendSymbol(at seconds: Int) -> String? {
        guard validAltitudeRoutes.count >= 3 else {
            return nil
        }
        
        let targetDate = workout.workout.startDate.addingTimeInterval(TimeInterval(seconds))
        
        guard let currentIndex = validAltitudeRoutes.indices.min(by: {
            abs(validAltitudeRoutes[$0].timestamp.timeIntervalSince(targetDate)) < abs(validAltitudeRoutes[$1].timestamp.timeIntervalSince(targetDate))
        }) else {
            return nil
        }
        
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
        
        var count = 0
        let results = workoutDetail.heartRate
            .compactMap { $0.value }
            .reduce(0) {
                count += 1
                return $0 + $1
            }
        
        return String(format: "%.0f", results / Double(count))
    }
    
    public var avgPace: String {
        self.workout.avgPace
    }
    
    public var avgPower: String? {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.power.isEmpty else { return nil }
        
        var count = 0
        let results = workoutDetail.power
            .compactMap { $0.value }
            .reduce(0) {
                count += 1
                return $0 + $1
            }
        
        return String(format: "%.0f", results / Double(count))
    }
    
    public var avgCadence: String? {
        guard let cadence = workoutDetail?.cadence else { return nil }
        
        return String(format: "%.0f", cadence)
    }
    
    public var avgVerticalOscillation: String? {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.verticalOscillation.isEmpty else { return nil }
        
        var count = 0
        let results = workoutDetail.verticalOscillation
            .compactMap { $0.value }
            .reduce(0) {
                count += 1
                return $0 + $1
            }
        
        return String(format: "%.1f", results / Double(count))
    }
    
    public var avgGroundContactTime: String? {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.groundContactTime.isEmpty else { return nil }
        
        var count = 0
        let results = workoutDetail.groundContactTime
            .compactMap { $0.value }
            .reduce(0) {
                count += 1
                return $0 + $1
            }
        
        return String(format: "%.0f", results / Double(count))
    }
    
    public var avgStrideLength: String? {
        guard let workoutDetail = workoutDetail,
              !workoutDetail.strideLength.isEmpty else { return nil }
        
        var count = 0
        let results = workoutDetail.strideLength
            .compactMap { $0.value }
            .reduce(0) {
                count += 1
                return $0 + $1
            }
        
        return String(format: "%.1f", results / Double(count))
    }
    
    public var elevationGain: String? {
        guard let routeData = workoutDetail?.routes else { return nil }
        return routeData.calculateTotalElevationGain()
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
    
    /// 분석 차트 오른쪽에 표시할 페이스 y축 tick 값을 생성합니다.
    public var analysisPaceYAxisValues: [Double] {
        let minValue = paceChartYScale.lowerBound
        let maxValue = paceChartYScale.upperBound
        
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
    
    /// 분석 차트 왼쪽에 표시할 고도 y축 tick 값을 생성합니다.
    public var analysisAltitudeYAxisValues: [Double] {
        guard altitudeChartYScale.lowerBound.isFinite,
              altitudeChartYScale.upperBound.isFinite,
              altitudeChartYScale.lowerBound != altitudeChartYScale.upperBound else {
            return []
        }
        
        return (0...3).map { index in
            let altitude = altitudeChartYScale.lowerBound + ((altitudeChartYScale.upperBound - altitudeChartYScale.lowerBound) / 3 * Double(index))
            return mappedAnalysisAltitudeValue(altitude)
        }
    }
    
    /// 분석 차트 x축에 표시할 경과 시간 tick 값을 시작/중간/끝 기준으로 생성합니다.
    public var analysisXAxisValues: [Int] {
        let lowerBound = paceChartXScale.lowerBound
        let upperBound = paceChartXScale.upperBound
        let duration = upperBound - lowerBound
        
        guard duration > 0 else {
            return [lowerBound]
        }
        
        return [0, 1, 2, 3].map { index in
            lowerBound + Int((Double(duration) / 3) * Double(index))
        }
    }
    
    /// 고도 값을 페이스 차트의 y축 좌표계에 맞춰 표시용 값으로 변환합니다.
    public func mappedAnalysisAltitudeValue(_ altitude: Double) -> Double {
        guard altitudeChartYScale.upperBound != altitudeChartYScale.lowerBound,
              paceChartYScale.upperBound != paceChartYScale.lowerBound else {
            return paceChartYScale.lowerBound
        }
        
        let ratio = (altitude - altitudeChartYScale.lowerBound) / (altitudeChartYScale.upperBound - altitudeChartYScale.lowerBound)
        return paceChartYScale.lowerBound + ((paceChartYScale.upperBound - paceChartYScale.lowerBound) * ratio)
    }
    
    /// 페이스 y축 좌표계로 변환된 고도 값을 실제 meter 라벨로 되돌립니다.
    public func analysisAltitudeLabel(for mappedValue: Double) -> String {
        guard paceChartYScale.upperBound != paceChartYScale.lowerBound else {
            return "--"
        }
        
        let ratio = (mappedValue - paceChartYScale.lowerBound) / (paceChartYScale.upperBound - paceChartYScale.lowerBound)
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


extension WorkoutRouteSegment {
    var centerCoordinate: CLLocationCoordinate2D? {
        guard !coordinates.isEmpty else {
            return nil
        }
        
        return coordinates[coordinates.count / 2]
    }
}

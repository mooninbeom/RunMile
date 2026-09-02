//
//  MapAnalysisBottomPanel.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI
import Charts


struct MapAnalysisBottomPanel: View {
    @Binding var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header
            
            HStack(spacing: 10) {
                AnalysisMetricPill(title: "페이스", value: viewModel.selectedPaceText, tint: RunMileColor.accent)
                AnalysisMetricPill(title: "심박", value: viewModel.selectedHeartRateText, unit: "bpm", tint: RunMileColor.primary)
                AnalysisMetricPill(
                    title: "고도",
                    value: viewModel.selectedAltitudeText,
                    unit: "m",
                    symbol: viewModel.selectedAltitudeTrendSymbol,
                    tint: RunMileColor.success
                )
            }
            
            PaceAnalysisChart(viewModel: $viewModel)
                .frame(height: 190)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .fill(RunMileColor.mapOverlaySurface)
                .shadow(color: RunMileColor.hardShadow, radius: 0, x: 4, y: 4)
        }
        .foregroundStyle(RunMileColor.cardForeground)
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
    
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("러닝 분석")
                    .font(.title3.weight(.black))
                
                Text(viewModel.selectedElapsedTimeText)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    viewModel.mapAnalysisCloseButtonTapped()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(RunMileColor.foreground, RunMileColor.muted)
            }
        }
    }
}


private struct PaceAnalysisChart: View {
    @Binding var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        Chart {
            ForEach(viewModel.analysisMappedAltitudeSamples) { sample in
                AreaMark(
                    x: .value("Time", sample.seconds),
                    yStart: .value("Altitude Base", viewModel.analysisPaceChartYScale.lowerBound),
                    yEnd: .value("Altitude", sample.rates)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [RunMileColor.success.opacity(0.045), RunMileColor.success.opacity(0.01)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            ForEach(viewModel.analysisMappedAltitudeSamples) { sample in
                LineMark(
                    x: .value("Time", sample.seconds),
                    y: .value("Altitude", sample.rates)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(RunMileColor.success.opacity(0.30))
            }
            
            ForEach(viewModel.analysisPaceSamples) { sample in
                LineMark(
                    x: .value("Time", sample.seconds),
                    y: .value("Pace", sample.rates),
                    series: .value("Segment", sample.groupID)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [RunMileColor.accent, RunMileColor.accent.opacity(0.72)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
        }
        .chartXScale(domain: viewModel.analysisPaceChartXScale)
        .chartYScale(domain: viewModel.analysisPaceChartYScale)
        .chartXAxis {
            AxisMarks(values: viewModel.analysisXAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(RunMileColor.chartGrid)
                
                AxisValueLabel {
                    if let seconds = value.as(Int.self) {
                        Text(viewModel.analysisTimeLabel(seconds: seconds))
                            .font(.caption2)
                            .monospacedDigit()
                            .foregroundStyle(RunMileColor.chartAxis)
                    } else if let seconds = value.as(Double.self) {
                        Text(viewModel.analysisTimeLabel(seconds: Int(seconds)))
                            .font(.caption2)
                            .monospacedDigit()
                            .foregroundStyle(RunMileColor.chartAxis)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: viewModel.analysisAltitudeYAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(RunMileColor.chartGrid)
                
                AxisValueLabel {
                    if let mappedValue = value.as(Double.self) {
                        Text(viewModel.analysisAltitudeLabel(for: mappedValue))
                            .foregroundStyle(RunMileColor.chart4.opacity(0.85))
                    }
                }
            }
            
            AxisMarks(position: .trailing, values: viewModel.analysisPaceYAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(RunMileColor.chartGrid)
                
                AxisValueLabel {
                    if let speed = value.as(Double.self) {
                        Text(speed.meterPerSecondToPace())
                            .foregroundStyle(RunMileColor.chartAxis)
                    }
                }
            }
        }
        .chartOverlay { chartProxy in
            GeometryReader { geometryProxy in
                ZStack {
                    if let selectedSeconds = viewModel.selectedSeconds,
                       let chartPlotFrame = chartProxy.plotFrame,
                       let selectedX = chartProxy.position(forX: selectedSeconds) {
                        let plotFrame = geometryProxy[chartPlotFrame]
                        let xPosition = plotFrame.origin.x + selectedX

                        Path { path in
                            path.move(to: CGPoint(x: xPosition, y: plotFrame.minY))
                            path.addLine(to: CGPoint(x: xPosition, y: plotFrame.maxY))
                        }
                        .stroke(
                            RunMileColor.foreground.opacity(0.55),
                            style: StrokeStyle(lineWidth: 2, dash: [4])
                        )
                    }

                    Rectangle()
                        .fill(.clear)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    guard let chartPlotFrame = chartProxy.plotFrame else { return }

                                    let plotFrame = geometryProxy[chartPlotFrame]
                                    let currentX = value.location.x - plotFrame.origin.x
                                    guard currentX >= 0, currentX <= plotFrame.width else { return }

                                    if let second: Int = chartProxy.value(atX: currentX) {
                                        viewModel.detailGraphTapped(seconds: second)
                                    }
                                }
                        )
                }
            }
        }
        .padding(14)
        .background(RunMileColor.surfaceElevated, in: RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


private struct AnalysisMetricPill: View {
    let title: String
    let value: String
    var unit: String?
    var symbol: String?
    let tint: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2.weight(.bold))
                .foregroundStyle(RunMileColor.mutedForeground)
            
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.subheadline.weight(.black))
                    .monospacedDigit()
                
                if let unit {
                    Text(unit)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
                
                if let symbol {
                    Image(systemName: symbol)
                        .font(.caption2.weight(.black))
                        .foregroundStyle(symbolColor(for: symbol))
                }
            }
            .foregroundStyle(RunMileColor.foreground)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
    
    private func symbolColor(for symbol: String) -> Color {
        switch symbol {
        case "arrow.up.right":
            return RunMileColor.elevationUp
        case "arrow.down.right":
            return RunMileColor.accent
        default:
            return RunMileColor.mutedForeground
        }
    }
}

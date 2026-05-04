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
                AnalysisMetricPill(title: "페이스", value: viewModel.selectedPaceText, tint: .blue)
                AnalysisMetricPill(title: "심박", value: viewModel.selectedHeartRateText, unit: "bpm", tint: .red)
                AnalysisMetricPill(
                    title: "고도",
                    value: viewModel.selectedAltitudeText,
                    unit: "m",
                    symbol: viewModel.selectedAltitudeTrendSymbol,
                    tint: .green
                )
            }
            
            PaceAnalysisChart(viewModel: $viewModel)
                .frame(height: 190)
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(Color(red: 0.12, green: 0.18, blue: 0.19).opacity(0.92), in: RoundedRectangle(cornerRadius: 28))
        .overlay {
            RoundedRectangle(cornerRadius: 28)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.28), radius: 18, x: 0, y: 10)
    }
    
    private var header: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: 4) {
                Text("러닝 분석")
                    .font(.title3.weight(.black))
                
                Text(viewModel.selectedElapsedTimeText)
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                    viewModel.mapAnalysisCloseButtonTapped()
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}


private struct PaceAnalysisChart: View {
    @Binding var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        Chart {
            ForEach(viewModel.altitudeSamples) { sample in
                AreaMark(
                    x: .value("Time", sample.seconds),
                    yStart: .value("Altitude Base", viewModel.paceChartYScale.lowerBound),
                    yEnd: .value("Altitude", viewModel.mappedAnalysisAltitudeValue(sample.rates))
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.green.opacity(0.045), .green.opacity(0.01)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            ForEach(viewModel.altitudeSamples) { sample in
                LineMark(
                    x: .value("Time", sample.seconds),
                    y: .value("Altitude", viewModel.mappedAnalysisAltitudeValue(sample.rates))
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
                .foregroundStyle(.green.opacity(0.30))
            }
            
            ForEach(viewModel.paceSamples) { sample in
                LineMark(
                    x: .value("Time", sample.seconds),
                    y: .value("Pace", sample.rates),
                    series: .value("Segment", sample.groupID)
                )
                .interpolationMethod(.catmullRom)
                .lineStyle(.init(lineWidth: 3, lineCap: .round, lineJoin: .round))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            }
            
            if let selectedSeconds = viewModel.selectedSeconds {
                RuleMark(x: .value("Selected", selectedSeconds))
                    .lineStyle(StrokeStyle(lineWidth: 2, dash: [4]))
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .chartXScale(domain: viewModel.paceChartXScale)
        .chartYScale(domain: viewModel.paceChartYScale)
        .chartXAxis {
            AxisMarks(values: viewModel.analysisXAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(.white.opacity(0.12))
                
                AxisValueLabel {
                    if let seconds = value.as(Int.self) {
                        Text(viewModel.analysisTimeLabel(seconds: seconds))
                            .font(.caption2)
                            .monospacedDigit()
                    } else if let seconds = value.as(Double.self) {
                        Text(viewModel.analysisTimeLabel(seconds: Int(seconds)))
                            .font(.caption2)
                            .monospacedDigit()
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: viewModel.analysisAltitudeYAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(.green.opacity(0.045))
                
                AxisValueLabel {
                    if let mappedValue = value.as(Double.self) {
                        Text(viewModel.analysisAltitudeLabel(for: mappedValue))
                            .foregroundStyle(.green.opacity(0.68))
                    }
                }
            }
            
            AxisMarks(position: .trailing, values: viewModel.analysisPaceYAxisValues) { value in
                AxisGridLine()
                    .foregroundStyle(.white.opacity(0.12))
                
                AxisValueLabel {
                    if let speed = value.as(Double.self) {
                        Text(speed.meterPerSecondToPace())
                    }
                }
            }
        }
        .chartOverlay { chartProxy in
            GeometryReader { geometryProxy in
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
        .padding(14)
        .background(.black.opacity(0.42), in: RoundedRectangle(cornerRadius: 18))
        .overlay {
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.08), lineWidth: 1)
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
                .foregroundStyle(.secondary)
            
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.subheadline.weight(.black))
                    .monospacedDigit()
                
                if let unit {
                    Text(unit)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.secondary)
                }
                
                if let symbol {
                    Image(systemName: symbol)
                        .font(.caption2.weight(.black))
                        .foregroundStyle(symbolColor(for: symbol))
                }
            }
            .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(tint.opacity(0.14), in: RoundedRectangle(cornerRadius: 14))
        .overlay {
            RoundedRectangle(cornerRadius: 14)
                .stroke(tint.opacity(0.22), lineWidth: 1)
        }
    }
    
    private func symbolColor(for symbol: String) -> Color {
        switch symbol {
        case "arrow.up.right":
            return .orange
        case "arrow.down.right":
            return .cyan
        default:
            return .white.opacity(0.75)
        }
    }
}

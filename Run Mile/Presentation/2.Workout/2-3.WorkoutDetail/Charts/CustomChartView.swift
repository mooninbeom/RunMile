//
//  CustomChartView.swift
//  Run Mile
//
//  Created by 문인범 on 1/2/26.
//

import SwiftUI
import Charts


struct CustomChartView: View {
    let category: ChartList

    let samples: [ChartSample]
    let xScale: ClosedRange<Int>
    let yScale: ClosedRange<Double>

    private var safeYScale: ClosedRange<Double> {
        ChartAxisValueFactory.safeYScale(for: yScale)
    }

    var body: some View {
        VStack(alignment: .leading) {
            Label(category.labelTitle, systemImage: category.symbolTitle)
                .foregroundStyle(category.color)
                .font(.headline)
                .padding(.horizontal)

            Chart {
                ForEach(samples) { point in
                    LineMark(
                        x: .value("Time", point.seconds),
                        y: .value("BPM", point.rates),
                        series: .value("Segment", point.groupID)
                    )
                    .foregroundStyle(category.color.gradient)
                    .interpolationMethod(.catmullRom)
                }
            }
            .chartYScale(domain: safeYScale)
            .frame(height: 200)
            .padding()
            .runMileBrutalCard()
            .padding(.horizontal)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(alignment: .bottom) {
                        // 차트 영역의 바닥(bottom)에 높이 1짜리 검은 선을 깔아라
                        Rectangle()
                            .fill(RunMileColor.border) // 선 색상
                            .frame(height: 1.5)  // 선 두께
                    }
            }
            .chartXAxis {
                let xAxisValues = ChartAxisValueFactory.xAxisValues(for: xScale)

                AxisMarks(values: xAxisValues) { axis in
                    AxisGridLine()
                        .foregroundStyle(RunMileColor.chartGrid)
                    let value = xAxisValues[axis.index]
                    let duration = Duration.seconds(value)
                    let formattedString = duration.formatted(.time(pattern: .hourMinuteSecond))
                    AxisValueLabel(formattedString, centered: false)
                        .foregroundStyle(RunMileColor.chartAxis)
                }
            }
            .chartYAxis {
                let yAxisValues = ChartAxisValueFactory.yAxisValues(for: safeYScale)

                AxisMarks(position: .trailing, values: yAxisValues) { axis in
                    AxisGridLine()
                        .foregroundStyle(RunMileColor.chartGrid)
                    let value = yAxisValues[axis.index]

                    switch self.category {
                    case .heart, .power, .groundContactTime:
                        AxisValueLabel(String(format: "%.0f", value), centered: false)
                            .foregroundStyle(RunMileColor.chartAxis)
                    case .pace:
                        AxisValueLabel(value.meterPerSecondToPace(), centered: false)
                            .foregroundStyle(RunMileColor.chartAxis)
                    case .verticalOscillation, .strideLength:
                        AxisValueLabel(String(format: "%.1f", value), centered: false)
                            .foregroundStyle(RunMileColor.chartAxis)
                    }
                }
            }
        }
    }
}


enum ChartAxisValueFactory {
    /// x축 범위에 맞춰 중복 없는 시간 라벨 값을 생성합니다.
    static func xAxisValues(for scale: ClosedRange<Int>) -> [Int] {
        guard scale.lowerBound < scale.upperBound else {
            return [scale.lowerBound]
        }

        let step = max((scale.upperBound - scale.lowerBound) / 4, 1)
        var values = Array(stride(from: scale.lowerBound, through: scale.upperBound, by: step))

        if values.last != scale.upperBound {
            values.append(scale.upperBound)
        }

        return values
    }

    /// 동일한 min/max 값이 들어와도 Charts가 그릴 수 있도록 y축 범위를 보정합니다.
    static func safeYScale(for scale: ClosedRange<Double>) -> ClosedRange<Double> {
        guard scale.lowerBound < scale.upperBound else {
            let padding = max(abs(scale.lowerBound) * 0.1, 1)
            return (scale.lowerBound - padding)...(scale.upperBound + padding)
        }

        return scale
    }

    /// y축 범위에 맞춰 최소/최대 포함 5개 라벨 값을 생성합니다.
    static func yAxisValues(for scale: ClosedRange<Double>) -> [Double] {
        let safeScale = safeYScale(for: scale)
        let step = (safeScale.upperBound - safeScale.lowerBound) / 4

        return (0...4).map { index in
            safeScale.lowerBound + (step * Double(index))
        }
    }
}

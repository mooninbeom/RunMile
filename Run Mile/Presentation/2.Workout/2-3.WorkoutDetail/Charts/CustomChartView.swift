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
            .chartYScale(domain: yScale)
            .frame(height: 200)
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(alignment: .bottom) {
                        // 차트 영역의 바닥(bottom)에 높이 1짜리 검은 선을 깔아라
                        Rectangle()
                            .fill(Color.white) // 선 색상
                            .frame(height: 1.5)  // 선 두께
                    }
            }
            .chartXAxis {
                let from = self.xScale.lowerBound
                let through = self.xScale.upperBound
                let stride = Array(stride(
                    from: from,
                    through: through,
                    by: (through - from) / 4
                ))
                
                AxisMarks(values: stride) { axis in
                    AxisGridLine()
                    let value = stride[axis.index]
                    let duration = Duration.seconds(value)
                    let formattedString = duration.formatted(.time(pattern: .hourMinuteSecond))
                    AxisValueLabel(formattedString, centered: false)
                }
            }
            .chartYAxis {
                let from = self.yScale.lowerBound
                let through = self.yScale.upperBound
                let stride = Array(stride(
                    from: from,
                    through: through,
                    by: (through - from) / 4
                ))
                
                AxisMarks(position: .trailing, values: stride) { axis in
                    AxisGridLine()
                    let value = stride[axis.index]
                    
                    switch self.category {
                    case .heart, .power, .groundContactTime:
                        AxisValueLabel(String(format: "%.0f", value), centered: false)
                    case .pace:
                        AxisValueLabel(value.meterPerSecondToPace(), centered: false)
                    case .verticalOscillation, .strideLength:
                        AxisValueLabel(String(format: "%.1f", value), centered: false)
                    }
                }
            }
        }
    }
}


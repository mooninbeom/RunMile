//
//  ChartSection.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI


struct ChartSection: View {
    @Binding var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            if !viewModel.heartRateSamples.isEmpty {
                CustomChartView(
                    category: .heart,
                    samples: viewModel.heartRateSamples,
                    xScale: viewModel.heartChartXScale,
                    yScale: viewModel.heartChartYScale
                )
            }
            
            if !viewModel.paceSamples.isEmpty {
                CustomChartView(
                    category: .pace,
                    samples: viewModel.paceSamples,
                    xScale: viewModel.paceChartXScale,
                    yScale: viewModel.paceChartYScale
                )
            }
            
            if !viewModel.powerSamples.isEmpty {
                CustomChartView(
                    category: .power,
                    samples: viewModel.powerSamples,
                    xScale: viewModel.powerChartXScale,
                    yScale: viewModel.powerChartYScale
                )
            }
            
            if !viewModel.verticalOscillationSamples.isEmpty {
                CustomChartView(
                    category: .verticalOscillation,
                    samples: viewModel.verticalOscillationSamples,
                    xScale: viewModel.verticalOscillationChartXScale,
                    yScale: viewModel.verticalOscillationChartYScale
                )
            }
        }
    }
}

//
//  SplitSection.swift
//  Run Mile
//
//  Created by 문인범 on 1/6/26.
//

import SwiftUI


struct SplitSection: View {
    @Binding var viewModel: WorkoutDetailViewModel
    
    var body: some View {
        if !viewModel.splits.isEmpty {
            VStack(alignment: .leading) {
                Text("구간 기록")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 0) {
                    ForEach(viewModel.visibleSplits) { split in
                        SplitRow(split: split)
                        
                        if let last = viewModel.visibleSplits.last,
                           last.id != split.id {
                            Divider()
                                .padding(.leading)
                        }
                    }
                    
                    if viewModel.shouldShowSplitMoreButton {
                        Divider()
                            .padding(.leading)
                        
                        Button {
                            withAnimation(.snappy) {
                                viewModel.splitMoreButtonTapped()
                            }
                        } label: {
                            HStack {
                                Text(viewModel.splitMoreButtonTitle)
                                    .font(.body.weight(.semibold))
                                
                                Spacer()
                                
                                Image(systemName: viewModel.splitMoreButtonIcon)
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundStyle(.secondary)
                            .padding()
                        }
                    }
                }
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
            }
        }
    }
}


private struct SplitRow: View {
    let split: SplitInfo
    
    var body: some View {
        HStack {
            Text("\(split.label) km")
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
            
            Spacer()
            
            Text(split.pace)
                .font(.monospacedDigit(.body)())
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

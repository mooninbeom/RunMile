//
//  HOFReportComponents.swift
//  Run Mile
//
//  Created by Codex on 5/17/26.
//

import SwiftUI


struct HOFReportSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label(title, systemImage: icon)
                .font(.title3)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)

            content
        }
        .padding(20)
        .runMileBrutalCard()
        .padding(.horizontal)
    }
}


struct HOFReportStatTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.mutedForeground)

            Text(value)
                .font(.headline)
                .fontWeight(.black)
                .foregroundStyle(RunMileColor.foreground)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
        }
    }
}


struct HOFDistanceRecordsBoard: View {
    let records: [HOFDistanceRecord]
    
    private var columns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "rosette")
                    .font(.headline.weight(.black))
                
                Text("거리별 최고 기록")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)
                
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(records) { record in
                    HOFDistanceRecordTile(record: record)
                }
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RunMileColor.muted, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


struct HOFDistanceRecordTile: View {
    let record: HOFDistanceRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(spacing: 6) {
                Text(record.title)
                    .font(.caption)
                    .fontWeight(.black)
                    .foregroundStyle(record.isAvailable ? RunMileColor.primaryText : RunMileColor.mutedForeground)
                
                Spacer(minLength: 4)
                
                if record.isPersonalBest {
                    Text("PB")
                        .font(.caption2)
                        .fontWeight(.black)
                        .foregroundStyle(RunMileColor.secondaryForeground)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 4)
                        .background(RunMileColor.secondary, in: RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: RunMileRadius.progress, style: .continuous)
                                .stroke(RunMileColor.border, lineWidth: RunMileStroke.hairline)
                        }
                }
            }
            
            Text(record.timeText)
                .font(.title3)
                .fontWeight(.black)
                .foregroundStyle(record.isAvailable ? RunMileColor.foreground : RunMileColor.mutedForeground)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            
            Text(record.detailText)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(RunMileColor.mutedForeground)
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .padding(12)
        .frame(minHeight: 106, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(record.isPersonalBest ? RunMileColor.secondary.opacity(0.22) : RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(record.isPersonalBest ? RunMileColor.primary : RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


struct HOFMemorableRunRow: View {
    let run: HOFMemorableRun

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: run.icon)
                .font(.headline)
                .foregroundStyle(run.isPrimary ? RunMileColor.secondaryForeground : RunMileColor.primaryForeground)
                .frame(width: 38, height: 38)
                .background(run.isPrimary ? RunMileColor.secondary : RunMileColor.primary, in: RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.small, style: .continuous)
                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(run.title)
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)

                Text(run.detail)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }

            Spacer()
        }
        .padding(12)
        .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: RunMileRadius.card, style: .continuous)
                .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
        }
    }
}


struct HOFMileageMilestoneRow: View {
    let milestone: HOFMileageMilestone

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                Circle()
                    .fill(milestone.isGraduation ? RunMileColor.primary : RunMileColor.secondary)
                    .frame(width: 18, height: 18)
                    .overlay {
                        Circle()
                            .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                    }

                if !milestone.isGraduation {
                    Rectangle()
                        .fill(RunMileColor.border)
                        .frame(width: 3, height: 36)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.subheadline)
                    .fontWeight(.black)
                    .foregroundStyle(RunMileColor.foreground)

                Text(milestone.dateText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(RunMileColor.mutedForeground)
            }
            .padding(.bottom, 18)

            Spacer()
        }
    }
}

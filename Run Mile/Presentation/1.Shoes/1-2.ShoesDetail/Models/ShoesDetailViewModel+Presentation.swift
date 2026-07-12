import SwiftUI


extension ShoesDetailViewModel {
    var averageDistance: String {
        let count = shoes.workouts.count
        guard count > 0 else { return "0.0km" }
        let average = shoes.totalMileage / Double(count)
        return String(format: "%.1fkm", average)
    }

    var shoeBrand: String {
        shoePresentationInfo.brand
    }

    var shoeModel: String {
        shoePresentationInfo.model
    }

    var lifeSpanRatio: Double {
        shoePresentationInfo.lifeSpanRatio
    }

    var remainingPercentText: String {
        shoePresentationInfo.remainingPercentText
    }

    var statusColor: Color {
        shoePresentationInfo.statusColor
    }

    var statusForegroundColor: Color {
        shoePresentationInfo.statusForegroundColor
    }

    private var shoePresentationInfo: ShoePresentationInfo {
        ShoePresentationInfo(shoe: shoes)
    }
}

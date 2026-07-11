import Foundation


extension ShoesDetailViewModel {
    enum ManagementSheet: Identifiable {
        case editInfo
        case workouts
        case delete

        var id: String {
            switch self {
            case .editInfo:
                "editInfo"
            case .workouts:
                "workouts"
            case .delete:
                "delete"
            }
        }
    }
}

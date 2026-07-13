import Foundation


struct AppUpdateInfo: Equatable, Sendable {
    let version: String
    let summary: String
    let highlights: [String]
    let appStoreURL: URL
}


enum AppUpdateConfiguration: Equatable, Sendable {
    case disabled
    case enabled(AppUpdateInfo)
}

import Foundation


protocol AppUpdatePreferenceStore: Sendable {
    func dismissedVersion() async -> String?
    func saveDismissedVersion(_ version: String) async
}

import Foundation


protocol AppStoreOpening: Sendable {
    @MainActor
    func open(_ url: URL) async -> Bool
}

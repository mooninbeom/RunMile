import UIKit


struct SystemAppStoreOpener: AppStoreOpening {
    @MainActor
    func open(_ url: URL) async -> Bool {
        await withCheckedContinuation { continuation in
            UIApplication.shared.open(url, options: [:]) { didOpen in
                continuation.resume(returning: didOpen)
            }
        }
    }
}

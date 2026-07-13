import Foundation


protocol AppUpdateUseCase: Sendable {
    func fetchAvailableUpdate() async throws -> AppUpdateInfo?
    func markUpdateAsDismissed(version: String) async

    @MainActor
    func openAppStore(at url: URL) async -> Bool
}


final class DefaultAppUpdateUseCase: AppUpdateUseCase {
    private let configurationRepository: AppUpdateConfigurationRepository
    private let preferenceStore: AppUpdatePreferenceStore
    private let versionProvider: AppVersionProviding
    private let appStoreOpener: AppStoreOpening

    init(
        configurationRepository: AppUpdateConfigurationRepository,
        preferenceStore: AppUpdatePreferenceStore,
        versionProvider: AppVersionProviding,
        appStoreOpener: AppStoreOpening
    ) {
        self.configurationRepository = configurationRepository
        self.preferenceStore = preferenceStore
        self.versionProvider = versionProvider
        self.appStoreOpener = appStoreOpener
    }

    func fetchAvailableUpdate() async throws -> AppUpdateInfo? {
        let configuration = try await configurationRepository.fetchConfiguration()
        guard case let .enabled(update) = configuration,
              let currentVersion = AppVersion(versionProvider.currentVersion),
              let latestVersion = AppVersion(update.version),
              currentVersion < latestVersion else {
            return nil
        }

        if let dismissedVersion = await preferenceStore.dismissedVersion(),
           let dismissedAppVersion = AppVersion(dismissedVersion),
           latestVersion <= dismissedAppVersion {
            return nil
        }
        return update
    }

    func markUpdateAsDismissed(version: String) async {
        guard AppVersion(version) != nil else { return }
        await preferenceStore.saveDismissedVersion(version)
    }

    @MainActor
    func openAppStore(at url: URL) async -> Bool {
        await appStoreOpener.open(url)
    }
}

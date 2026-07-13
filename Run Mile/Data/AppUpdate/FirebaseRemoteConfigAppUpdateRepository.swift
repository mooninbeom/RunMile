import FirebaseRemoteConfig
import Foundation


actor FirebaseRemoteConfigAppUpdateRepository: AppUpdateConfigurationRepository {
    private enum Key {
        static let isEnabled = "ios_update_enabled"
        static let latestVersion = "ios_latest_version"
        static let message = "ios_update_message"
        static let highlights = "ios_update_highlights"
        static let storeURL = "ios_update_store_url"
    }

    private let minimumFetchInterval: TimeInterval
    private let mapper = AppUpdateRemoteConfigMapper()

    init(minimumFetchInterval: TimeInterval? = nil) {
        self.minimumFetchInterval = minimumFetchInterval ?? Self.defaultMinimumFetchInterval
    }

    func fetchConfiguration() async throws -> AppUpdateConfiguration {
        let remoteConfig = configuredRemoteConfig()

        do {
            _ = try await remoteConfig.fetchAndActivate()
        } catch {
            // 네트워크 요청이 실패하면 마지막으로 활성화된 값 또는 기본값을 사용합니다.
        }
        return try mapper.map(values(from: remoteConfig))
    }
}


private extension FirebaseRemoteConfigAppUpdateRepository {
    static var defaultMinimumFetchInterval: TimeInterval {
        #if DEBUG
        0
        #else
        6 * 60 * 60
        #endif
    }

    func configuredRemoteConfig() -> RemoteConfig {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = minimumFetchInterval
        settings.fetchTimeout = 10
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults([
            Key.isEnabled: NSNumber(value: false),
            Key.latestVersion: "" as NSString,
            Key.message: "" as NSString,
            Key.highlights: "[]" as NSString,
            Key.storeURL: "" as NSString
        ])
        return remoteConfig
    }

    func values(from remoteConfig: RemoteConfig) -> AppUpdateRemoteConfigValues {
        AppUpdateRemoteConfigValues(
            isEnabled: remoteConfig[Key.isEnabled].boolValue,
            latestVersion: remoteConfig[Key.latestVersion].stringValue,
            message: remoteConfig[Key.message].stringValue,
            highlights: remoteConfig[Key.highlights].stringValue,
            storeURL: remoteConfig[Key.storeURL].stringValue
        )
    }
}

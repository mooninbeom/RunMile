import Foundation


struct AppUpdateRemoteConfigValues: Sendable {
    let isEnabled: Bool
    let latestVersion: String
    let message: String
    let highlights: String
    let storeURL: String
}


struct AppUpdateRemoteConfigMapper {
    func map(_ values: AppUpdateRemoteConfigValues) throws -> AppUpdateConfiguration {
        guard values.isEnabled else { return .disabled }

        let latestVersion = trimmed(values.latestVersion)
        let message = trimmed(values.message)
        let highlights = try decodedHighlights(from: values.highlights)
        let storeURLString = trimmed(values.storeURL)

        guard AppVersion(latestVersion) != nil else {
            throw AppUpdateRemoteConfigError.invalidValue(.latestVersion)
        }
        guard !message.isEmpty else {
            throw AppUpdateRemoteConfigError.invalidValue(.message)
        }
        guard let storeURL = URL(string: storeURLString), storeURL.scheme == "https" else {
            throw AppUpdateRemoteConfigError.invalidValue(.storeURL)
        }

        return .enabled(AppUpdateInfo(
            version: latestVersion,
            summary: message,
            highlights: highlights,
            appStoreURL: storeURL
        ))
    }
}


private extension AppUpdateRemoteConfigMapper {
    func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func decodedHighlights(from rawValue: String) throws -> [String] {
        guard let data = rawValue.data(using: .utf8),
              let values = try? JSONDecoder().decode([String].self, from: data) else {
            throw AppUpdateRemoteConfigError.invalidValue(.highlights)
        }

        let highlights = values.map(trimmed)
        guard !highlights.isEmpty, highlights.allSatisfy({ !$0.isEmpty }) else {
            throw AppUpdateRemoteConfigError.invalidValue(.highlights)
        }
        return highlights
    }
}


enum AppUpdateRemoteConfigError: Error, Equatable {
    case invalidValue(AppUpdateRemoteConfigField)
}


enum AppUpdateRemoteConfigField: Equatable {
    case latestVersion
    case message
    case highlights
    case storeURL
}

import Foundation


protocol AppUpdateConfigurationRepository: Sendable {
    func fetchConfiguration() async throws -> AppUpdateConfiguration
}

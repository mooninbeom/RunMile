import Foundation
import XCTest
@testable import Run_Mile


final class AppUpdateUseCaseTests: XCTestCase {
    func testNumericVersionComparisonHandlesDifferentComponentLengths() throws {
        let older = try XCTUnwrap(AppVersion("1.9"))
        let newer = try XCTUnwrap(AppVersion("1.10"))
        let equivalent = try XCTUnwrap(AppVersion("1.10.0"))

        XCTAssertLessThan(older, newer)
        XCTAssertEqual(newer, equivalent)
    }

    func testMalformedVersionIsRejected() {
        XCTAssertNil(AppVersion("2.0-beta"))
        XCTAssertNil(AppVersion("2..0"))
    }

    func testAvailableUpdateReturnsEnabledNewerVersion() async throws {
        let update = try makeUpdate(version: "2.1.0")
        let useCase = makeUseCase(configuration: .enabled(update), currentVersion: "2.0.0")

        let result = try await useCase.fetchAvailableUpdate()

        XCTAssertEqual(result, update)
    }

    func testAvailableUpdateIgnoresEquivalentVersion() async throws {
        let update = try makeUpdate(version: "2.0.0")
        let useCase = makeUseCase(configuration: .enabled(update), currentVersion: "2.0")

        let result = try await useCase.fetchAvailableUpdate()

        XCTAssertNil(result)
    }

    func testAvailableUpdateIgnoresDismissedVersion() async throws {
        let update = try makeUpdate(version: "2.1.0")
        let preferenceStore = FakeAppUpdatePreferenceStore(dismissedVersion: "2.1.0")
        let useCase = makeUseCase(
            configuration: .enabled(update),
            currentVersion: "2.0.0",
            preferenceStore: preferenceStore
        )

        let result = try await useCase.fetchAvailableUpdate()

        XCTAssertNil(result)
    }

    func testAvailableUpdateReturnsVersionNewerThanDismissedVersion() async throws {
        let update = try makeUpdate(version: "2.2.0")
        let preferenceStore = FakeAppUpdatePreferenceStore(dismissedVersion: "2.1.0")
        let useCase = makeUseCase(
            configuration: .enabled(update),
            currentVersion: "2.0.0",
            preferenceStore: preferenceStore
        )

        let result = try await useCase.fetchAvailableUpdate()

        XCTAssertEqual(result, update)
    }

    func testMarkUpdateAsDismissedPersistsVersion() async {
        let preferenceStore = FakeAppUpdatePreferenceStore()
        let useCase = makeUseCase(
            configuration: .disabled,
            currentVersion: "2.0.0",
            preferenceStore: preferenceStore
        )

        await useCase.markUpdateAsDismissed(version: "2.1.0")

        let dismissedVersion = await preferenceStore.dismissedVersion()
        XCTAssertEqual(dismissedVersion, "2.1.0")
    }

    @MainActor
    func testOpenAppStoreDelegatesToSystemOpener() async throws {
        let recorder = OpenedURLRecorder()
        let opener = FakeAppStoreOpener(recorder: recorder)
        let useCase = makeUseCase(
            configuration: .disabled,
            currentVersion: "2.0.0",
            appStoreOpener: opener
        )
        let url = try XCTUnwrap(URL(string: "https://apps.apple.com/app/id123456789"))

        let didOpen = await useCase.openAppStore(at: url)
        let openedURLs = await recorder.values()

        XCTAssertTrue(didOpen)
        XCTAssertEqual(openedURLs, [url])
    }
}


private func makeUseCase(
    configuration: AppUpdateConfiguration,
    currentVersion: String,
    preferenceStore: AppUpdatePreferenceStore = FakeAppUpdatePreferenceStore(),
    appStoreOpener: AppStoreOpening = FakeAppStoreOpener()
) -> DefaultAppUpdateUseCase {
    DefaultAppUpdateUseCase(
        configurationRepository: FakeAppUpdateConfigurationRepository(configuration: configuration),
        preferenceStore: preferenceStore,
        versionProvider: FakeAppVersionProvider(currentVersion: currentVersion),
        appStoreOpener: appStoreOpener
    )
}


private func makeUpdate(version: String) throws -> AppUpdateInfo {
    let url = try XCTUnwrap(URL(string: "https://apps.apple.com/app/id123456789"))
    return AppUpdateInfo(
        version: version,
        summary: "업데이트 안내",
        highlights: ["새로운 기능"],
        appStoreURL: url
    )
}


private struct FakeAppUpdateConfigurationRepository: AppUpdateConfigurationRepository {
    let configuration: AppUpdateConfiguration

    func fetchConfiguration() async throws -> AppUpdateConfiguration {
        configuration
    }
}


private actor FakeAppUpdatePreferenceStore: AppUpdatePreferenceStore {
    private var version: String?

    init(dismissedVersion: String? = nil) {
        version = dismissedVersion
    }

    func dismissedVersion() -> String? {
        version
    }

    func saveDismissedVersion(_ version: String) {
        self.version = version
    }
}


private struct FakeAppVersionProvider: AppVersionProviding {
    let currentVersion: String
}


private struct FakeAppStoreOpener: AppStoreOpening {
    let recorder: OpenedURLRecorder?

    init(recorder: OpenedURLRecorder? = nil) {
        self.recorder = recorder
    }

    @MainActor
    func open(_ url: URL) async -> Bool {
        await recorder?.append(url)
        return true
    }
}


private actor OpenedURLRecorder {
    private var urls: [URL] = []

    func append(_ url: URL) {
        urls.append(url)
    }

    func values() -> [URL] {
        urls
    }
}

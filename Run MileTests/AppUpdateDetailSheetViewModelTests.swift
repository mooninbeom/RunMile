import Foundation
import XCTest
@testable import Run_Mile


final class AppUpdateDetailSheetViewModelTests: XCTestCase {
    @MainActor
    func testLaterButtonOnlyDismissesSheet() async throws {
        let useCase = AppUpdateUseCaseSpy()
        var didDismiss = false
        let viewModel = AppUpdateDetailSheetViewModel(
            info: try makePresentationInfo(),
            useCase: useCase,
            dismissAction: { didDismiss = true }
        )

        viewModel.laterButtonTapped()
        let dismissedVersions = await useCase.dismissedVersions()

        XCTAssertTrue(didDismiss)
        XCTAssertTrue(dismissedVersions.isEmpty)
    }
}


private func makePresentationInfo() throws -> AppUpdatePresentationInfo {
    let url = try XCTUnwrap(URL(string: "https://apps.apple.com/app/id123456789"))
    return AppUpdatePresentationInfo(
        version: "2.1.0",
        summary: "업데이트 안내",
        highlights: ["새로운 기능"],
        appStoreURL: url
    )
}


private actor AppUpdateUseCaseSpy: AppUpdateUseCase {
    private var versions: [String] = []

    func fetchAvailableUpdate() async throws -> AppUpdateInfo? {
        nil
    }

    func markUpdateAsDismissed(version: String) async {
        versions.append(version)
    }

    @MainActor
    func openAppStore(at url: URL) async -> Bool {
        true
    }

    func dismissedVersions() -> [String] {
        versions
    }
}

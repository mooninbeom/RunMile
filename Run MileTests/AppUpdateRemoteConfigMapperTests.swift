import Foundation
import XCTest
@testable import Run_Mile


final class AppUpdateRemoteConfigMapperTests: XCTestCase {
    private let mapper = AppUpdateRemoteConfigMapper()

    func testDisabledConfigurationDoesNotRequireUpdateValues() throws {
        let values = makeValues(isEnabled: false, latestVersion: "", message: "", highlights: "", storeURL: "")

        let configuration = try mapper.map(values)

        XCTAssertEqual(configuration, .disabled)
    }

    func testValidConfigurationTrimsAndMapsValues() throws {
        let values = makeValues(
            latestVersion: " 2.1.0 ",
            message: " 신발 이미지를 수정할 수 있어요. ",
            highlights: "[\" 이미지 수정 \", \" 크기 조절 \"]",
            storeURL: " https://apps.apple.com/app/id123456789 "
        )

        let configuration = try mapper.map(values)
        let expectedURL = try XCTUnwrap(URL(string: "https://apps.apple.com/app/id123456789"))

        XCTAssertEqual(configuration, .enabled(AppUpdateInfo(
            version: "2.1.0",
            summary: "신발 이미지를 수정할 수 있어요.",
            highlights: ["이미지 수정", "크기 조절"],
            appStoreURL: expectedURL
        )))
    }

    func testInvalidVersionIsRejected() {
        XCTAssertThrowsError(try mapper.map(makeValues(latestVersion: "2.1-beta"))) { error in
            XCTAssertEqual(error as? AppUpdateRemoteConfigError, .invalidValue(.latestVersion))
        }
    }

    func testInvalidHighlightsJSONIsRejected() {
        XCTAssertThrowsError(try mapper.map(makeValues(highlights: "not-json"))) { error in
            XCTAssertEqual(error as? AppUpdateRemoteConfigError, .invalidValue(.highlights))
        }
    }

    func testNonHTTPSStoreURLIsRejected() {
        XCTAssertThrowsError(try mapper.map(makeValues(storeURL: "http://apps.apple.com/app/id123456789"))) { error in
            XCTAssertEqual(error as? AppUpdateRemoteConfigError, .invalidValue(.storeURL))
        }
    }
}


private func makeValues(
    isEnabled: Bool = true,
    latestVersion: String = "2.1.0",
    message: String = "업데이트 안내",
    highlights: String = "[\"새로운 기능\"]",
    storeURL: String = "https://apps.apple.com/app/id123456789"
) -> AppUpdateRemoteConfigValues {
    AppUpdateRemoteConfigValues(
        isEnabled: isEnabled,
        latestVersion: latestVersion,
        message: message,
        highlights: highlights,
        storeURL: storeURL
    )
}

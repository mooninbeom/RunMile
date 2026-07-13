import Foundation


struct AppUpdatePresentationInfo: Equatable, Sendable {
    let version: String
    let summary: String
    let highlights: [String]
    let appStoreURL: URL

    init(
        version: String,
        summary: String,
        highlights: [String],
        appStoreURL: URL
    ) {
        self.version = version
        self.summary = summary
        self.highlights = highlights
        self.appStoreURL = appStoreURL
    }

    init(update: AppUpdateInfo) {
        self.init(
            version: update.version,
            summary: update.summary,
            highlights: update.highlights,
            appStoreURL: update.appStoreURL
        )
    }

    var versionText: String {
        "v\(version)"
    }

    var cardAccessibilityLabel: String {
        "새 버전 \(versionText)이 도착했어요. \(summary)"
    }
}


#if DEBUG
extension AppUpdatePresentationInfo {
    static let preview = AppUpdatePresentationInfo(
        version: "2.1.0",
        summary: "이제 등록한 신발 이미지를 원하는 사진으로 바꿀 수 있어요.",
        highlights: [
            "신발 상세 화면에서 이미지를 바로 수정할 수 있어요.",
            "선택한 사진의 위치와 크기를 원하는 모습으로 조정할 수 있어요.",
            "수정한 이미지는 신발 목록과 상세 화면에 함께 반영돼요."
        ],
        appStoreURL: URL(fileURLWithPath: "/app-store-preview")
    )
}
#endif

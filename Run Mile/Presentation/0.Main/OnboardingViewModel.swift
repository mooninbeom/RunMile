//
//  OnboardingViewModel.swift
//  Run Mile
//
//  Created by Codex on 6/16/26.
//

import Foundation


@Observable
final class OnboardingViewModel {
    private let useCase: HealthDataUseCase
    private let healthAuthorizationPageIndex = 1

    public private(set) var currentIndex = 0
    public private(set) var isRequestingHealthAuthorization = false

    init(useCase: HealthDataUseCase) {
        self.useCase = useCase
    }
}


extension OnboardingViewModel {
    /// 온보딩 CTA 탭 흐름을 처리하고, 건강 데이터 연결 페이지에서는 권한 요청 완료 후 다음 페이지로 이동합니다.
    @MainActor
    public func primaryButtonTapped(
        pageCount: Int,
        onFinish: () -> Void
    ) async {
        guard !isRequestingHealthAuthorization else { return }

        if currentIndex >= pageCount - 1 {
            onFinish()
            return
        }

        if currentIndex == healthAuthorizationPageIndex {
            await requestHealthAuthorizationThenAdvance(
                pageCount: pageCount,
                onFinish: onFinish
            )
            return
        }

        advance(pageCount: pageCount, onFinish: onFinish)
    }

    @MainActor
    private func requestHealthAuthorizationThenAdvance(
        pageCount: Int,
        onFinish: () -> Void
    ) async {
        isRequestingHealthAuthorization = true
        defer { isRequestingHealthAuthorization = false }

        do {
            try await useCase.checkHealthAuthorization()
        } catch {
            // 권한 요청 실패는 운동 탭에서 재시도할 수 있으므로 온보딩 진행을 막지 않습니다.
        }

        advance(pageCount: pageCount, onFinish: onFinish)
    }

    @MainActor
    private func advance(
        pageCount: Int,
        onFinish: () -> Void
    ) {
        guard currentIndex < pageCount - 1 else {
            onFinish()
            return
        }

        currentIndex += 1
    }
}

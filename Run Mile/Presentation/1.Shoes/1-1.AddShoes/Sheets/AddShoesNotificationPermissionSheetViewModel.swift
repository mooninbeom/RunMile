//
//  AddShoesNotificationPermissionSheetViewModel.swift
//  Run Mile
//
//  Created by Codex on 6/17/26.
//

import Foundation


@Observable
final class AddShoesNotificationPermissionSheetViewModel {
    private let useCase: NotificationPermissionUseCase

    public var isRequestingNotificationPermission = false

    init(useCase: NotificationPermissionUseCase) {
        self.useCase = useCase
    }
}


extension AddShoesNotificationPermissionSheetViewModel {
    @MainActor
    public func confirmButtonTapped() {
        guard !isRequestingNotificationPermission else { return }

        Task {
            await requestNotificationAuthorizationAndDismiss()
        }
    }

    @MainActor
    private func requestNotificationAuthorizationAndDismiss() async {
        isRequestingNotificationPermission = true
        defer { isRequestingNotificationPermission = false }

        do {
            try await useCase.requestNotificationAuthorization()
        } catch {
            NavigationCoordinator.shared.push(.init(
                title: "알림 권한 요청 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }

        NavigationCoordinator.shared.dismissCustomSheet()
    }
}

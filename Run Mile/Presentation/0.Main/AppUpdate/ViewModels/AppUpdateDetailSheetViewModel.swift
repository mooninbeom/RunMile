import Foundation


@Observable
final class AppUpdateDetailSheetViewModel {
    let info: AppUpdatePresentationInfo

    private let useCase: AppUpdateUseCase
    private let dismissAction: @MainActor () -> Void

    init(
        info: AppUpdatePresentationInfo,
        useCase: AppUpdateUseCase,
        dismissAction: @escaping @MainActor () -> Void
    ) {
        self.info = info
        self.useCase = useCase
        self.dismissAction = dismissAction
    }

    @MainActor
    func updateButtonTapped() {
        Task {
            _ = await useCase.openAppStore(at: info.appStoreURL)
            dismissAction()
        }
    }

    @MainActor
    func laterButtonTapped() {
        dismissAction()
    }
}

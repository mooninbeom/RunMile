//
//  ShoesListViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import Foundation


@Observable
final class ShoesListViewModel {
    public var shoes: [Shoes] = []
    public var monthlyDistanceText: String = "연동 후 표시"
    public private(set) var appUpdateInfo: AppUpdatePresentationInfo?
    
    private let useCase: ShoesListUseCase
    private let appUpdateUseCase: AppUpdateUseCase
    private var isCheckingForUpdate = false
    
    init(
        useCase: ShoesListUseCase,
        appUpdateUseCase: AppUpdateUseCase
    ) {
        self.useCase = useCase
        self.appUpdateUseCase = appUpdateUseCase
    }
    
    public var shoeCardItems: [ShoePresentationInfo] {
        shoes.map { ShoePresentationInfo(shoe: $0) }
    }
}


extension ShoesListViewModel {
    @MainActor
    public func addShoesButtonTapped() {
        NavigationCoordinator.shared.push(.addShoes {
            self.onAppear()
        })
    }
    
    @MainActor
    public func shoesCellTapped(_ shoes: Shoes) {
        NavigationCoordinator.shared
            .push(.shoesDetail(shoes), tab: .shoes)
    }

    @MainActor
    public func appUpdateButtonTapped() {
        guard let appUpdateInfo else { return }
        NavigationCoordinator.shared.presentCustomSheet(.appUpdate(appUpdateInfo))
    }

    @MainActor
    public func appUpdateDismissButtonTapped() {
        guard let appUpdateInfo else { return }
        self.appUpdateInfo = nil

        Task {
            await appUpdateUseCase.markUpdateAsDismissed(version: appUpdateInfo.version)
        }
    }

    @MainActor
    public func appDidBecomeActive() {
        fetchAvailableUpdate()
    }

    @MainActor
    public func onAppear() {
        Task {
            do {
                self.shoes = try await useCase.fetchShoes()
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "데이터 로딩 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
        
        Task {
            await fetchMonthlyRunningDistance()
        }

        fetchAvailableUpdate()
    }
    
    /// HealthKit 권한이 준비되지 않은 경우 알럿 없이 월간 거리 플레이스홀더를 유지합니다.
    @MainActor
    private func fetchMonthlyRunningDistance() async {
        do {
            let monthlyDistance = try await useCase.fetchMonthlyRunningDistance()
            self.monthlyDistanceText = String(format: "%.1f km", monthlyDistance)
        } catch {
            self.monthlyDistanceText = "연동 후 표시"
            
            #if DEBUG
            print("[ShoesListViewModel] monthly distance unavailable: \(error.localizedDescription)")
            #endif
        }
    }

    @MainActor
    private func fetchAvailableUpdate() {
        guard !isCheckingForUpdate else { return }
        isCheckingForUpdate = true

        Task {
            defer { isCheckingForUpdate = false }

            do {
                appUpdateInfo = try await appUpdateUseCase.fetchAvailableUpdate()
                    .map(AppUpdatePresentationInfo.init(update:))
            } catch {
                appUpdateInfo = nil
            }
        }
    }
}

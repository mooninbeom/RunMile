//
//  ShoesDetailViewModel.swift
//  Run Mile
//
//  Created by 문인범 on 4/19/25.
//

import Foundation
import SwiftUI


@Observable
final class ShoesDetailViewModel {
    private let useCase: ShoesDetailUseCase
    
    public var shoes: Shoes
    public var activeManagementSheet: ManagementSheet?
    public var editBrand = ShoeCatalog.defaultBrand {
        didSet {
            guard oldValue != editBrand else { return }
            editModel = ShoeCatalog.defaultModel(for: editBrand)
        }
    }
    public var editModel = ShoeCatalog.defaultModel
    public var editCustomBrand = ""
    public var editCustomModel = ""
    public var editUsage = ""
    public var editGoalMileage = ""
    public var selectedWorkoutIDs: Set<UUID> = []
    
    public var averageDistance: String {
        let count = shoes.workouts.count
        guard count > 0 else { return "0.0km" }
        let avg = shoes.totalMileage / Double(count)
        return String(format: "%.1fkm", avg)
    }
    
    private var shoePresentationInfo: ShoePresentationInfo {
        ShoePresentationInfo(shoe: shoes)
    }
    
    public var shoeBrand: String {
        shoePresentationInfo.brand
    }
    
    public var shoeModel: String {
        shoePresentationInfo.model
    }
    
    public var lifeSpanRatio: Double {
        shoePresentationInfo.lifeSpanRatio
    }
    
    public var remainingPercentText: String {
        shoePresentationInfo.remainingPercentText
    }
    
    public var statusColor: Color {
        shoePresentationInfo.statusColor
    }
    
    public var statusForegroundColor: Color {
        shoePresentationInfo.statusForegroundColor
    }
    
    public var isEditSaveEnabled: Bool {
        !effectiveEditedShoesName.isEmpty &&
        !editUsage.trimmed.isEmpty &&
        editGoalMileageValue != nil
    }
    
    public var editBrandList: [String] {
        ShoeCatalog.brandList
    }
    
    public var editModelList: [String] {
        ShoeCatalog.modelList(for: editBrand)
    }
    
    init(useCase: ShoesDetailUseCase, shoes: Shoes) {
        self.useCase = useCase
        self.shoes = shoes
    }
    
    /// 신발 상세 관리 액션에서 표시할 시트를 구분합니다.
    enum ManagementSheet: Identifiable {
        case editInfo
        case workouts
        case delete
        
        var id: String {
            switch self {
            case .editInfo:
                "editInfo"
            case .workouts:
                "workouts"
            case .delete:
                "delete"
            }
        }
    }
}


extension ShoesDetailViewModel {
    /// 신발 정보 수정 시트를 열기 전 현재 신발 정보를 편집 상태에 반영합니다.
    @MainActor
    public func editInfoButtonTapped() {
        prepareEditSheet()
        activeManagementSheet = .editInfo
    }
    
    /// 연결된 운동 관리 시트를 열고 이전 선택 상태를 초기화합니다.
    @MainActor
    public func workoutManagementButtonTapped() {
        selectedWorkoutIDs.removeAll()
        activeManagementSheet = .workouts
    }
    
    /// 신발 삭제 확인 시트를 표시합니다.
    @MainActor
    public func deleteManagementButtonTapped() {
        activeManagementSheet = .delete
    }
    
    /// 현재 표시 중인 신발 관리 시트를 닫습니다.
    @MainActor
    public func dismissManagementSheet() {
        activeManagementSheet = nil
    }
    
    /// 편집 시트의 입력값으로 신발 정보를 저장합니다.
    @MainActor
    public func saveEditedShoes() {
        guard let goalMileage = editGoalMileageValue else { return }
        
        let modified = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: effectiveEditedShoesName,
            nickname: editUsage.trimmed,
            goalMileage: goalMileage,
            currentMileage: shoes.currentMileage,
            workouts: shoes.workouts,
            isGraduate: shoes.isGradutate
        )
        
        Task {
            await updateShoes(modified)
        }
    }
    
    /// 선택한 운동과 신발의 연결을 해제합니다.
    @MainActor
    public func removeSelectedWorkouts() {
        guard !selectedWorkoutIDs.isEmpty else { return }
        
        let workoutIDs = selectedWorkoutIDs
        let modified = makeShoes(removingWorkoutIDs: workoutIDs)
        
        Task {
            await updateShoes(modified)
            self.selectedWorkoutIDs.removeAll()
        }
    }
    
    /// 신발 삭제를 실행하고 삭제 완료 후 현재 탭에서 이전 화면으로 돌아갑니다.
    @MainActor
    public func deleteShoesFromSheet() {
        let currentTab = NavigationCoordinator.shared.tabStatus
        Task {
            await deleteShoes(currentTab: currentTab)
        }
    }
    
    @MainActor
    public func workoutCellTapped(_ workout: Workout) {
        let currentTab = NavigationCoordinator.shared.tabStatus
        NavigationCoordinator.shared.push(.workoutDetail(workout), tab: currentTab)
    }
    
    @MainActor
    public func HOFButtonTapped() {
        let alert = AlertData(
            title: "정말로 진행하시겠습니까?",
            message: "명예의 전당으로 간 신발은 더 이상 마일리지를 추가할 수 없습니다.",
            firstButton: .cancel(title: "취소", action: {}),
            secondButton: .ok(title: "확인", action: editShoesHOF)
        )
        
        NavigationCoordinator.shared.push(alert)
    }
    
    @MainActor
    public func imageTapped() {
        let currentTab = NavigationCoordinator.shared.tabStatus
        NavigationCoordinator.shared.push(.imageDetail(shoes.image), tab: currentTab)
    }
}


// MARK: - Internal Function
extension ShoesDetailViewModel {
    private func prepareEditSheet() {
        let selection = ShoeCatalog.selection(for: shoes.shoesName)
        
        editBrand = selection.selectedBrand
        editModel = selection.selectedModel
        editCustomBrand = selection.customBrand
        editCustomModel = selection.customModel
        editUsage = shoes.nickname
        editGoalMileage = shoes.getGoalMileage
    }
    
    private var effectiveEditedShoesName: String {
        ShoeCatalog.shoesName(
            selectedBrand: editBrand,
            selectedModel: editModel,
            customBrand: editCustomBrand,
            customModel: editCustomModel
        )
    }
    
    private var editGoalMileageValue: Double? {
        let value = Double(editGoalMileage.trimmed)
        guard let value, value > 0 else { return nil }
        return value
    }
    
    /// 지정한 운동 ID를 제외한 신발 모델을 생성합니다.
    private func makeShoes(removingWorkoutIDs workoutIDs: Set<UUID>) -> Shoes {
        let remainingWorkouts = shoes.workouts.filter {
            !workoutIDs.contains($0.id)
        }
        
        return Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: shoes.goalMileage,
            currentMileage: shoes.currentMileage,
            workouts: remainingWorkouts,
            isGraduate: shoes.isGradutate
        )
    }
    
    /// 신발 변경사항을 저장하고 현재 화면 상태를 최신 데이터로 갱신합니다.
    @MainActor
    private func updateShoes(_ modified: Shoes) async {
        do {
            try await useCase.editShoes(shoes: modified)
            self.shoes = modified
            self.activeManagementSheet = nil
        } catch {
            NavigationCoordinator.shared.push(.init(
                title: "저장 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            ))
        }
    }
    
    @MainActor
    private func deleteShoes(currentTab: NavigationCoordinator.TabStatus) async {
        do {
            try await useCase.deleteShoes(shoes: self.shoes)
            self.activeManagementSheet = nil
            
            let alert = AlertData(
                title: "삭제를 완료했습니다.",
                message: nil,
                firstButton: .cancel(title: "확인") {
                    Task {
                        await NavigationCoordinator.shared.pop(currentTab)
                    }
                },
                secondButton: nil
            )
            
            NavigationCoordinator.shared.push(alert)
        } catch {
            let alert = AlertData(
                title: "삭제 과정 중 오류가 발생했습니다.",
                message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                firstButton: .cancel(title: "확인", action: {}),
                secondButton: nil
            )
            
            NavigationCoordinator.shared.push(alert)
        }
    }
    
    private func editShoesHOF() {
        let modified = Shoes(
            id: shoes.id,
            image: shoes.image,
            shoesName: shoes.shoesName,
            nickname: shoes.nickname,
            goalMileage: shoes.goalMileage,
            currentMileage: shoes.currentMileage,
            workouts: shoes.workouts,
            isGraduate: true
        )
        
        Task {
            do {
                try await self.useCase.graduateShoes(shoes: modified)
                await NavigationCoordinator.shared.pop(.shoes)
            } catch {
                await NavigationCoordinator.shared.push(.init(
                    title: "저장 과정 중 오류가 발생했습니다.",
                    message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
                    firstButton: .cancel(title: "확인", action: {}),
                    secondButton: nil
                ))
            }
        }
    }
}


private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

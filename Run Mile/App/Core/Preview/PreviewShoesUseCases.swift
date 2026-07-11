//
//  PreviewShoesUseCases.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import Foundation
import PhotosUI
import SwiftUI


struct PreviewShoesListUseCase: ShoesListUseCase {
    let shoes: [Shoes]
    let monthlyDistance: Double
    
    /// 신발 목록 Preview에 사용할 샘플 신발 데이터를 반환합니다.
    func fetchShoes() async throws -> [Shoes] {
        shoes
    }
    
    /// 신발 목록 Preview에 사용할 이번 달 전체 러닝 거리를 반환합니다.
    func fetchMonthlyRunningDistance() async throws -> Double {
        monthlyDistance
    }
}


struct PreviewShoesDetailUseCase: ShoesDetailUseCase {
    /// Preview에서는 저장소를 변경하지 않고 편집 완료 흐름만 통과시킵니다.
    func editShoes(shoes: Shoes) async throws {}
    
    /// Preview에서는 저장소를 변경하지 않고 삭제 완료 흐름만 통과시킵니다.
    func deleteShoes(shoes: Shoes) async throws {}
    
    /// Preview에서는 저장소를 변경하지 않고 명예의 전당 등록 흐름만 통과시킵니다.
    func graduateShoes(shoes: Shoes) async throws {}

    func normalizeImage(from imageData: Data) async throws -> Data {
        imageData
    }

    func removeImageBackground(from imageData: Data) async throws -> Data {
        imageData
    }
}


struct PreviewAddShoesUseCase: AddShoesUseCase {
    /// Preview에서는 선택된 사진 데이터를 그대로 빈 이미지 데이터로 대체합니다.
    func photoToData(photo: PhotosPickerItem) async throws -> Data {
        Data()
    }

    /// Preview에서는 저장소를 변경하지 않고 저장 완료 흐름만 통과시킵니다.
    func saveShoes(shoes: Shoes) async throws -> AddShoesSaveResult {
        AddShoesSaveResult(shouldShowNotificationPermissionSheet: true)
    }
}


struct PreviewNotificationPermissionUseCase: NotificationPermissionUseCase {
    /// Preview에서는 실제 알림 권한 요청을 실행하지 않습니다.
    func requestNotificationAuthorization() async throws {}
}
#endif

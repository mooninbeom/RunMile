//
//  PreviewMyPageUseCases.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

#if DEBUG
import Foundation


struct PreviewMyPageUseCase: MyPageUseCase {
    /// Preview에서는 메일 작성 가능 상태로 고정해 문의 화면 노출을 확인할 수 있게 합니다.
    func evaluateMailAvailable() -> Bool {
        true
    }
}


struct PreviewHOFUseCase: HOFUseCase {
    /// 명예의 전당 Preview에 사용할 졸업 신발 목록을 반환합니다.
    func fetchShoes() async throws -> [Shoes] {
        PreviewShoesMockData.hallOfFameShoes
    }
}
#endif

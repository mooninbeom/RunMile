//
//  ShoeCatalog.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import Foundation


enum ShoeCatalog {
    static let other = "기타"
    static let defaultBrand = "Adidas"
    static let defaultModel = "아디스타 4"
    
    static let brandOrder = [
        "Adidas",
        "Nike",
        "Asics",
        "New Balance",
        "On",
        "Saucony",
        "Brooks",
        "Puma",
        "Hoka",
        "Mizuno",
        "Salomon"
    ]
    
    static let brands: [String: [String]] = [
        "Nike": [
            "페가수스 42",
            "페가수스 프리미엄",
            "보메로 18",
            "보메로 플러스",
            "보메로 프리미엄",
            "스트럭처 26",
            "스트럭처 플러스",
            "라이벌플라이 4",
            "페가수스 플러스",
            "줌 플라이 6",
            "스트릭플라이 2",
            "베이퍼플라이 4",
            "알파플라이 3",
            other
        ],
        "Asics": [
            "젤 큐뮬러스 28",
            "젤님버스 28",
            "글라이드라이드 맥스 2",
            "GT2000 14",
            "젤카야노 33",
            "노바블라스트 5",
            "에보라이드 스피드 3",
            "슈퍼블라스트 3",
            "메가블라스트",
            "소닉블라스트",
            "매직스피드 5",
            "S4+ 요기리",
            "메타스피드 도쿄 스카이 · 엣지",
            "메타스피드 레이",
            other
        ],
        "Hoka": [
            "클리프톤 10",
            "본디 9",
            "아라히 8",
            "가비오타 6",
            "스카이플로우",
            "링컨 4",
            "마하 7",
            "마하 X3",
            "스카이워드 X",
            "로켓 X3",
            "씨엘로 X1 3.0",
            other
        ],
        "New Balance": [
            "880 V15",
            "엘리스 V1",
            "모어 V6",
            "봉고 V6",
            "860 V15",
            "1080 V15",
            "레벨 V5",
            "발로스",
            "SC트레이너 V3",
            "SC페이서 V2",
            "SC엘리트 V5",
            other
        ],
        "Adidas": [
            "아디스타 4",
            "슈퍼노바 라이즈 3",
            "슈퍼노바 프리마 2",
            "슈퍼노바 솔루션 3",
            "SL 2",
            "아디오스 9",
            "에보 SL",
            "하이퍼부스트 엣지",
            "보스턴 13",
            "프라임 X3 스트렁",
            "타쿠미 센 11",
            "아디오스 프로 4",
            "프로 에보 3",
            "프라임 X 에보",
            other
        ],
        "Brooks": [
            "고스트 17",
            "고스트 맥스 3",
            "글리세린 23",
            "글리세린 맥스 2",
            "아드레날린 GTS 25",
            "글리세린 GTS 23",
            "하이페리온 GTS 2",
            "글리세린 플렉스",
            "하이페리온 3",
            "하이페리온 맥스 3",
            "하이페리온 엘리트 5",
            other
        ],
        "Saucony": [
            "타이드 2",
            "라이드 19",
            "트라이엄프 24",
            "가이드 19",
            "템퍼스 3",
            "허리케인 25",
            "킨바라 16",
            "엔돌핀 아주라",
            "엔돌핀 스피드 5",
            "엔돌핀 트레이너",
            "엔돌핀 프로 5",
            "엔돌핀 엘리트 2",
            other
        ],
        "On": [
            "클라우드 서퍼 2",
            "클라우드 서퍼 넥스트",
            "클라우드 서퍼 맥스",
            "클라우드 러너 3",
            "클라우드 몬스터 3",
            "클라우드 몬스터 3 하이퍼",
            "클라우드 몬스터 3 하이퍼 LS",
            "클라우드 플로우 5",
            "클라우드붐 볼트",
            "클라우드붐 맥스",
            "클라우드붐 스트라이크",
            "클라우드붐 스트라이크 LS",
            other
        ],
        "Puma": [
            "일렉트리파이 나이트로 4",
            "매그니파이 나이트로 3",
            "매그맥스 나이트로 2",
            "포에버런 나이트로 2",
            "벨로시티 나이트로 4",
            "디비에이트 퓨어 나이트로",
            "디비에이트 나이트로 4",
            "프로피오 나이트로",
            "디비에이트 나이트로 엘리트 4",
            "패스트R 나이트로 엘리트 3",
            other
        ],
        "Mizuno": [
            "웨이브 라이더 29",
            "네오 코스모",
            "웨이브 스카이 9",
            "웨이브 호라이즌 8",
            "웨이브 인스파이어 22",
            "네오 젠 2",
            "네오 비스타 2",
            "하이퍼워프 프로",
            "하이퍼워프 퓨어",
            "하이퍼워프 엘리트",
            other
        ],
        "Salomon": [
            other
        ],
        other: []
    ]
    
    static var brandList: [String] {
        brandOrder.filter { brands[$0] != nil } + [other]
    }
    
    static func modelList(for brand: String) -> [String] {
        brands[brand] ?? []
    }
    
    static func defaultModel(for brand: String) -> String {
        modelList(for: brand).first ?? ""
    }
    
    /// 선택된 브랜드/모델과 직접 입력값을 실제 저장할 신발 이름으로 변환합니다.
    static func shoesName(
        selectedBrand: String,
        selectedModel: String,
        customBrand: String,
        customModel: String
    ) -> String {
        let brand = selectedBrand == other ? customBrand.trimmed : selectedBrand
        let model = selectedBrand == other || selectedModel == other ? customModel.trimmed : selectedModel
        
        return [brand, model]
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
    
    /// 저장된 신발 이름을 브랜드/모델 선택 상태로 복원합니다.
    static func selection(for shoesName: String) -> ShoeCatalogSelection {
        let trimmedName = shoesName.trimmed
        
        for brand in knownBrandsByLength {
            guard trimmedName == brand || trimmedName.hasPrefix("\(brand) ") else { continue }
            
            let model = trimmedName == brand
            ? ""
            : String(trimmedName.dropFirst(brand.count)).trimmed
            
            if modelList(for: brand).contains(model) {
                return ShoeCatalogSelection(
                    selectedBrand: brand,
                    selectedModel: model,
                    customBrand: "",
                    customModel: ""
                )
            }
            
            return ShoeCatalogSelection(
                selectedBrand: brand,
                selectedModel: other,
                customBrand: "",
                customModel: model
            )
        }
        
        let components = trimmedName.split(separator: " ", maxSplits: 1).map(String.init)
        return ShoeCatalogSelection(
            selectedBrand: other,
            selectedModel: "",
            customBrand: components.first ?? "",
            customModel: components.dropFirst().first ?? ""
        )
    }
    
    private static var knownBrandsByLength: [String] {
        brandList
            .filter { $0 != other }
            .sorted { $0.count > $1.count }
    }
}


struct ShoeCatalogSelection {
    let selectedBrand: String
    let selectedModel: String
    let customBrand: String
    let customModel: String
}


private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

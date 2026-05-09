//
//  ShoeCatalog.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import Foundation


enum ShoeCatalog {
    static let other = "기타"
    static let defaultBrand = "Nike"
    static let defaultModel = "Alphafly 3"
    
    static let brands: [String: [String]] = [
        "Nike": ["Alphafly 3", "Vaporfly 3", "Pegasus 41", "Invite Run 3", other],
        "Adidas": ["Adizero Adios Pro 3", "Adizero Takumi Sen 10", "Ultraboost Light", other],
        "New Balance": ["FuelCell SuperComp Elite v4", "Fresh Foam X 1080v13", other],
        "Hoka": ["Clifton 9", "Bondi 8", "Mach 6", "Rocket X 2", other],
        "Saucony": ["Endorphin Pro 4", "Endorphin Speed 4", "Ride 17", other],
        "Asics": ["Metaspeed Sky Paris", "Metaspeed Edge Paris", "Novablast 4", "Gel-Nimbus 26", other],
        "Mizuno": ["Wave Rebellion Pro 2", "Wave Rider 27", other],
        "Brooks": ["Ghost 15", "Glycerin 21", "Hyperion Elite 4", other],
        other: []
    ]
    
    static var brandList: [String] {
        brands.keys.sorted().filter { $0 != other } + [other]
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

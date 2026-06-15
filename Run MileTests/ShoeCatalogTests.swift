//
//  ShoeCatalogTests.swift
//  Run MileTests
//
//  Created by Codex on 6/14/26.
//

import Testing
@testable import Run_Mile


struct ShoeCatalogTests {
    @Test func defaultBrandStartsWithAdidas() {
        #expect(ShoeCatalog.defaultBrand == "Adidas")
        #expect(ShoeCatalog.defaultModel == "아디스타 4")
        #expect(ShoeCatalog.brandList.first == "Adidas")
    }
    
    @Test func knownShoesNameRestoresCatalogSelection() {
        let selection = ShoeCatalog.selection(for: "Adidas 아디스타 4")
        
        #expect(selection.selectedBrand == "Adidas")
        #expect(selection.selectedModel == "아디스타 4")
        #expect(selection.customBrand.isEmpty)
        #expect(selection.customModel.isEmpty)
    }
    
    @Test func removedCatalogModelRestoresAsCustomModel() {
        let selection = ShoeCatalog.selection(for: "Nike 오래된 모델")
        
        #expect(selection.selectedBrand == "Nike")
        #expect(selection.selectedModel == ShoeCatalog.other)
        #expect(selection.customBrand.isEmpty)
        #expect(selection.customModel == "오래된 모델")
    }
}

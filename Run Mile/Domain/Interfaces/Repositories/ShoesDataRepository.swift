//
//  ShoesDataRepository.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import Foundation


protocol ShoesDataRepository: Sendable {
    func fetchAllShoes() async throws -> [Shoes]
    func fetchHOFShoes() async throws -> [Shoes]
    func fetchCurrentShoes() async throws -> [Shoes]
    func fetchSingleShoes(id: UUID) async throws -> Shoes
}

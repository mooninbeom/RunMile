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
    
    func createShoes(shoes: Shoes) async throws
    func updateShoes(shoes: Shoes) async throws
    func deleteShoes(shoes: Shoes) async throws
}

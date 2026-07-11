import Foundation


protocol ShoeImageProcessingService: Sendable {
    func normalizeImage(from imageData: Data) async throws -> Data
    func removeBackground(from imageData: Data) async throws -> Data
}

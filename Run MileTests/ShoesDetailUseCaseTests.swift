import Foundation
import ImageIO
import Testing
import UIKit
import UniformTypeIdentifiers
@testable import Run_Mile


struct ShoesDetailUseCaseTests {
    @Test func editShoesPersistsReplacementImage() async throws {
        // Given
        let originalShoes = makeShoes(imageData: Data([0x01]))
        let replacementShoes = makeShoes(
            id: originalShoes.id,
            imageData: Data([0x02])
        )
        let repository = FakeShoesDetailRepository(shoes: originalShoes)
        let useCase = makeUseCase(repository: repository)

        // When
        try await useCase.editShoes(shoes: replacementShoes)

        // Then
        let savedShoes = try await repository.fetchSingleShoes(id: originalShoes.id)
        #expect(savedShoes.image == replacementShoes.image)
    }

    @Test func removeImageBackgroundReturnsServiceResult() async throws {
        // Given
        let sourceImage = Data([0x01])
        let processedImage = Data([0x02])
        let repository = FakeShoesDetailRepository(shoes: makeShoes(imageData: sourceImage))
        let imageService = FakeImageProcessingService(result: processedImage)
        let useCase = makeUseCase(
            repository: repository,
            imageService: imageService
        )

        // When
        let result = try await useCase.removeImageBackground(from: sourceImage)

        // Then
        #expect(result == processedImage)
        #expect(await imageService.receivedImageData() == sourceImage)
    }

    @Test func normalizeImageLimitsDimensionsAndRemovesGPSMetadata() async throws {
        // Given
        let sourceImage = try makeLargeJPEGWithGPSMetadata()
        let service = VisionShoeImageProcessingService()

        // When
        let normalizedImage = try await service.normalizeImage(from: sourceImage)

        // Then
        let source = try #require(CGImageSourceCreateWithData(normalizedImage as CFData, nil))
        let properties = try #require(
            CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any]
        )
        let width = try #require(properties[kCGImagePropertyPixelWidth] as? Int)
        let height = try #require(properties[kCGImagePropertyPixelHeight] as? Int)
        #expect(max(width, height) <= 1600)
        #expect(properties[kCGImagePropertyGPSDictionary] == nil)
    }
}


private func makeUseCase(
    repository: ShoesDataRepository,
    imageService: ShoeImageProcessingService = FakeImageProcessingService(result: Data())
) -> DefaultShoesDetailUseCase {
    DefaultShoesDetailUseCase(
        repository: repository,
        mileageGoalNotificationService: FakeShoesDetailMileageGoalNotificationService(),
        imageProcessingService: imageService
    )
}


private actor FakeShoesDetailRepository: ShoesDataRepository {
    private var shoes: Shoes

    init(shoes: Shoes) {
        self.shoes = shoes
    }

    func fetchAllShoes() async throws -> [Shoes] {
        [shoes]
    }

    func fetchHOFShoes() async throws -> [Shoes] {
        shoes.isGradutate ? [shoes] : []
    }

    func fetchCurrentShoes() async throws -> [Shoes] {
        shoes.isGradutate ? [] : [shoes]
    }

    func fetchSingleShoes(id: UUID) async throws -> Shoes {
        guard shoes.id == id else {
            throw FakeShoesDetailRepositoryError.shoesNotFound
        }
        return shoes
    }

    func createShoes(shoes: Shoes) async throws {
        self.shoes = shoes
    }

    func updateShoes(shoes: Shoes) async throws {
        self.shoes = shoes
    }

    func registerWorkouts(
        shoes: Shoes,
        workouts: [Workout],
        shouldMoveRegisteredWorkouts: Bool
    ) async throws {
        self.shoes = shoes
    }

    func deleteShoes(shoes: Shoes) async throws {}

    func updateSelectedShoes(shoes: Shoes) async {}
}


private actor FakeImageProcessingService: ShoeImageProcessingService {
    private let result: Data
    private var receivedImage: Data?

    init(result: Data) {
        self.result = result
    }

    func normalizeImage(from imageData: Data) async throws -> Data {
        imageData
    }

    func removeBackground(from imageData: Data) async throws -> Data {
        receivedImage = imageData
        return result
    }

    func receivedImageData() -> Data? {
        receivedImage
    }
}


private actor FakeShoesDetailMileageGoalNotificationService: MileageGoalNotificationService {
    func requestGoalReachedNotification(shoes: Shoes) async {}
}


private enum FakeShoesDetailRepositoryError: Error {
    case shoesNotFound
}


private func makeShoes(
    id: UUID = UUID(),
    imageData: Data
) -> Shoes {
    Shoes(
        id: id,
        image: imageData,
        shoesName: "Adidas 아디스타 4",
        nickname: "데일리 러닝",
        goalMileage: 700,
        currentMileage: 0,
        workouts: []
    )
}


private func makeLargeJPEGWithGPSMetadata() throws -> Data {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 2400, height: 1200)).image { context in
        UIColor.red.setFill()
        context.fill(CGRect(x: 0, y: 0, width: 2400, height: 1200))
    }
    let cgImage = try #require(image.cgImage)
    let data = NSMutableData()
    let destination = try #require(
        CGImageDestinationCreateWithData(
            data,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        )
    )
    let metadata: [CFString: Any] = [
        kCGImagePropertyGPSDictionary: [
            kCGImagePropertyGPSLatitude: 37.5665,
            kCGImagePropertyGPSLongitude: 126.9780
        ]
    ]
    CGImageDestinationAddImage(destination, cgImage, metadata as CFDictionary)
    #expect(CGImageDestinationFinalize(destination))
    return data as Data
}

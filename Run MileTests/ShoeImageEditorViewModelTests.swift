import Foundation
import Testing
@testable import Run_Mile


struct ShoeImageEditorViewModelTests {
    @Test @MainActor
    func backgroundRemovalUpdatesDisplayedImage() async {
        // Given
        let originalImage = Data([0x01])
        let removedImage = Data([0x02])
        let viewModel = ShoeImageEditorViewModel(
            imageData: originalImage,
            normalizeImage: { $0 },
            removeBackground: { _ in removedImage }
        )

        // When
        viewModel.backgroundButtonTapped()
        await waitUntilProcessingFinishes(viewModel)

        // Then
        #expect(viewModel.imageData == removedImage)
        #expect(viewModel.isBackgroundRemoved)
    }

    @Test @MainActor
    func backgroundRemovalCanRestoreOriginalImage() async {
        // Given
        let originalImage = Data([0x01])
        let removedImage = Data([0x02])
        let viewModel = ShoeImageEditorViewModel(
            imageData: originalImage,
            normalizeImage: { $0 },
            removeBackground: { _ in removedImage }
        )
        viewModel.backgroundButtonTapped()
        await waitUntilProcessingFinishes(viewModel)

        // When
        viewModel.backgroundButtonTapped()

        // Then
        #expect(viewModel.imageData == originalImage)
        #expect(!viewModel.isBackgroundRemoved)
    }

    @Test @MainActor
    func cancelledEditingIgnoresLateImageResult() async {
        // Given
        let originalImage = Data([0x01])
        let selectedImage = Data([0x02])
        let normalizer = DeferredImageNormalizer()
        let viewModel = ShoeImageEditorViewModel(
            imageData: originalImage,
            normalizeImage: { imageData in
                try await normalizer.normalize(imageData)
            },
            removeBackground: { $0 }
        )

        // When
        viewModel.cameraImagePicked(selectedImage)
        await normalizer.waitUntilStarted()
        viewModel.cancelEditing()
        await normalizer.waitUntilCancelled()
        await Task.yield()

        // Then
        #expect(viewModel.imageData == originalImage)
        #expect(!viewModel.isProcessing)
    }

    @Test @MainActor
    func saveEditedShoesUsesReplacementImage() async {
        // Given
        let originalImage = Data([0x01])
        let replacementImage = Data([0x02])
        let useCase = FakeShoesDetailViewModelUseCase()
        let viewModel = ShoesDetailViewModel(
            useCase: useCase,
            shoes: makeEditorShoes(imageData: originalImage)
        )
        viewModel.editInfoButtonTapped()
        viewModel.imageEditorViewModel.cameraImagePicked(replacementImage)
        await waitUntilProcessingFinishes(viewModel.imageEditorViewModel)

        // When
        viewModel.saveEditedShoes()
        let savedShoes = await useCase.waitForEditedShoes()

        // Then
        #expect(savedShoes.image == replacementImage)
    }
}


@MainActor
private func waitUntilProcessingFinishes(_ viewModel: ShoeImageEditorViewModel) async {
    for _ in 0..<1_000 where viewModel.isProcessing {
        await Task.yield()
    }
    #expect(!viewModel.isProcessing)
}


private actor DeferredImageNormalizer {
    private var hasStarted = false
    private var wasCancelled = false
    private var startContinuation: CheckedContinuation<Void, Never>?
    private var cancellationContinuation: CheckedContinuation<Void, Never>?
    private var resultContinuation: CheckedContinuation<Data, any Error>?

    func normalize(_ imageData: Data) async throws -> Data {
        hasStarted = true
        startContinuation?.resume()
        startContinuation = nil

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                resultContinuation = continuation
            }
        } onCancel: {
            Task {
                await self.cancel()
            }
        }
    }

    func waitUntilStarted() async {
        guard !hasStarted else { return }
        await withCheckedContinuation { continuation in
            startContinuation = continuation
        }
    }

    func waitUntilCancelled() async {
        guard !wasCancelled else { return }
        await withCheckedContinuation { continuation in
            cancellationContinuation = continuation
        }
    }

    private func cancel() {
        wasCancelled = true
        cancellationContinuation?.resume()
        cancellationContinuation = nil
        resultContinuation?.resume(throwing: CancellationError())
        resultContinuation = nil
    }
}


private actor FakeShoesDetailViewModelUseCase: ShoesDetailUseCase {
    private var editedShoes: Shoes?
    private var editContinuation: CheckedContinuation<Shoes, Never>?

    func editShoes(shoes: Shoes) async throws {
        editedShoes = shoes
        editContinuation?.resume(returning: shoes)
        editContinuation = nil
    }

    func deleteShoes(shoes: Shoes) async throws {}

    func graduateShoes(shoes: Shoes) async throws {}

    func normalizeImage(from imageData: Data) async throws -> Data {
        imageData
    }

    func removeImageBackground(from imageData: Data) async throws -> Data {
        imageData
    }

    func waitForEditedShoes() async -> Shoes {
        if let editedShoes {
            return editedShoes
        }
        return await withCheckedContinuation { continuation in
            editContinuation = continuation
        }
    }
}


private func makeEditorShoes(imageData: Data) -> Shoes {
    Shoes(
        id: UUID(),
        image: imageData,
        shoesName: "Adidas 아디스타 4",
        nickname: "데일리 러닝",
        goalMileage: 700,
        currentMileage: 0,
        workouts: []
    )
}

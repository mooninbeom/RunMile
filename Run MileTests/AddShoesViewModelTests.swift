import Foundation
import PhotosUI
import SwiftUI
import Testing
@testable import Run_Mile


struct AddShoesViewModelTests {
    @Test @MainActor
    func newerCameraImageIgnoresLateResultFromCancelledTask() async {
        let deferredImage = Data([0x01])
        let newerImage = Data([0x02])
        let useCase = DeferredAddShoesUseCase(deferredImage: deferredImage)
        let viewModel = AddShoesViewModel(useCase: useCase)

        viewModel.cameraImagePicked(deferredImage)
        await useCase.waitUntilStarted()
        viewModel.cameraImagePicked(newerImage)
        await waitUntilImageProcessingFinishes(viewModel)
        await useCase.completeDeferredRequest(with: deferredImage)
        await Task.yield()

        #expect(viewModel.image == newerImage)
        #expect(!viewModel.isLoading)
    }

    @Test @MainActor
    func disappearingViewCancelsImageProcessing() async {
        let deferredImage = Data([0x01])
        let useCase = DeferredAddShoesUseCase(deferredImage: deferredImage)
        let viewModel = AddShoesViewModel(useCase: useCase)

        viewModel.cameraImagePicked(deferredImage)
        await useCase.waitUntilStarted()
        viewModel.viewDidDisappear()
        await useCase.completeDeferredRequest(with: deferredImage)
        await Task.yield()

        #expect(viewModel.image == nil)
        #expect(!viewModel.isLoading)
    }

    @Test @MainActor
    func replacingBackgroundRemovedImageCannotRestoreOriginalImage() async {
        let originalImage = Data([0x01])
        let replacementImage = Data([0x02])
        let removedImage = Data([0x03])
        let useCase = DeferredAddShoesUseCase(
            deferredImage: Data([0xFF]),
            backgroundResult: removedImage
        )
        let viewModel = AddShoesViewModel(useCase: useCase)

        viewModel.cameraImagePicked(originalImage)
        await waitUntilImageProcessingFinishes(viewModel)
        viewModel.removeBackgroundButtonTapped()
        await waitUntilImageProcessingFinishes(viewModel)

        viewModel.cameraImagePicked(replacementImage)
        await waitUntilImageProcessingFinishes(viewModel)

        #expect(viewModel.image == replacementImage)
        #expect(!viewModel.isImageBackgroundRemoved)

        viewModel.removeBackgroundButtonTapped()
        await waitUntilImageProcessingFinishes(viewModel)
        viewModel.removeBackgroundButtonTapped()

        #expect(viewModel.image == replacementImage)
        #expect(!viewModel.isImageBackgroundRemoved)
    }
}


@MainActor
private func waitUntilImageProcessingFinishes(_ viewModel: AddShoesViewModel) async {
    let timeout = ContinuousClock.now + .seconds(2)

    while viewModel.isLoading && ContinuousClock.now < timeout {
        try? await Task.sleep(for: .milliseconds(10))
    }
    #expect(!viewModel.isLoading)
}


private actor DeferredAddShoesUseCase: AddShoesUseCase {
    private let deferredImage: Data
    private let backgroundResult: Data
    private var hasStarted = false
    private var startContinuation: CheckedContinuation<Void, Never>?
    private var resultContinuation: CheckedContinuation<Data, Never>?

    init(deferredImage: Data, backgroundResult: Data = Data()) {
        self.deferredImage = deferredImage
        self.backgroundResult = backgroundResult
    }

    func photoToData(photo: PhotosPickerItem) async throws -> Data {
        Data()
    }

    func normalizeImage(from imageData: Data) async throws -> Data {
        guard imageData == deferredImage else { return imageData }

        hasStarted = true
        startContinuation?.resume()
        startContinuation = nil

        return await withCheckedContinuation { continuation in
            resultContinuation = continuation
        }
    }

    func removeImageBackground(from imageData: Data) async throws -> Data {
        backgroundResult
    }

    func saveShoes(shoes: Shoes) async throws -> AddShoesSaveResult {
        AddShoesSaveResult(shouldShowNotificationPermissionSheet: false)
    }

    func waitUntilStarted() async {
        guard !hasStarted else { return }
        await withCheckedContinuation { continuation in
            startContinuation = continuation
        }
    }

    func completeDeferredRequest(with imageData: Data) {
        resultContinuation?.resume(returning: imageData)
        resultContinuation = nil
    }
}

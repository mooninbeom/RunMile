import Foundation
import SwiftUI
import PhotosUI


@MainActor
@Observable
final class ShoeImageEditorViewModel {
    typealias ImageNormalization = @Sendable (Data) async throws -> Data
    typealias BackgroundRemoval = @Sendable (Data) async throws -> Data

    var imageData: Data
    var photo: PhotosPickerItem? {
        didSet {
            guard photo != nil else { return }
            let sessionID = editSessionID
            isProcessing = true
            processingTask?.cancel()
            processingTask = Task {
                await photoPicked(sessionID: sessionID)
            }
        }
    }
    var isPhotoSourcePresented = false
    var isPhotoPickerPresented = false
    var isCameraPresented = false
    var isBackgroundRemoved = false
    var isProcessing = false

    private let normalizeImage: ImageNormalization
    private let removeBackground: BackgroundRemoval
    private var imageBeforeBackgroundRemoval: Data?
    private var isImageNormalized = false
    private var editSessionID = UUID()
    private var processingTask: Task<Void, Never>?

    init(
        imageData: Data,
        normalizeImage: @escaping ImageNormalization,
        removeBackground: @escaping BackgroundRemoval
    ) {
        self.imageData = imageData
        self.normalizeImage = normalizeImage
        self.removeBackground = removeBackground
    }

    @MainActor
    func reset(imageData: Data) {
        processingTask?.cancel()
        processingTask = nil
        self.imageData = imageData
        photo = nil
        imageBeforeBackgroundRemoval = nil
        isImageNormalized = false
        editSessionID = UUID()
        isBackgroundRemoved = false
        isProcessing = false
    }

    @MainActor
    func cancelEditing() {
        processingTask?.cancel()
        processingTask = nil
        editSessionID = UUID()
        photo = nil
        isPhotoSourcePresented = false
        isPhotoPickerPresented = false
        isCameraPresented = false
        isProcessing = false
    }

    @MainActor
    func photoButtonTapped() {
        isPhotoSourcePresented = true
    }

    @MainActor
    func photoLibraryButtonTapped() {
        isPhotoPickerPresented = true
    }

    @MainActor
    func cameraButtonTapped() {
        isCameraPresented = true
    }

    @MainActor
    func cameraImagePicked(_ imageData: Data) {
        let sessionID = editSessionID
        isProcessing = true
        processingTask?.cancel()
        processingTask = Task {
            do {
                let normalizedImage = try await normalizeImage(imageData)
                guard !Task.isCancelled, editSessionID == sessionID else { return }
                applySelectedImage(normalizedImage)
            } catch {
                guard !Task.isCancelled, editSessionID == sessionID else { return }
                presentError(
                    title: "사진 처리 과정 중 오류가 발생했습니다.",
                    error: error
                )
            }
            if editSessionID == sessionID {
                isProcessing = false
            }
        }
    }

    @MainActor
    func backgroundButtonTapped() {
        if isBackgroundRemoved {
            restoreImageBackground()
            return
        }

        let sourceImage = imageData
        let sessionID = editSessionID
        isProcessing = true

        processingTask?.cancel()
        processingTask = Task {
            do {
                let normalizedImage = isImageNormalized
                    ? sourceImage
                    : try await normalizeImage(sourceImage)
                let processedImage = try await removeBackground(normalizedImage)
                guard !Task.isCancelled, editSessionID == sessionID else { return }
                imageBeforeBackgroundRemoval = normalizedImage
                imageData = processedImage
                isImageNormalized = true
                isBackgroundRemoved = true
            } catch {
                guard !Task.isCancelled, editSessionID == sessionID else { return }
                presentError(
                    title: "이미지 배경 처리 과정 중 오류가 발생했습니다.",
                    error: error
                )
            }
            if editSessionID == sessionID {
                isProcessing = false
            }
        }
    }

    @MainActor
    private func photoPicked(sessionID: UUID) async {
        guard let photo else { return }

        do {
            guard let imageData = try await photo.loadTransferable(type: Data.self) else {
                throw ShoeImageEditingError.transferFailed
            }
            let normalizedImage = try await normalizeImage(imageData)
            guard !Task.isCancelled, editSessionID == sessionID else { return }
            applySelectedImage(normalizedImage)
        } catch {
            guard !Task.isCancelled, editSessionID == sessionID else { return }
            presentError(
                title: "사진 선택 과정 중 오류가 발생했습니다.",
                error: error
            )
        }
        if editSessionID == sessionID {
            self.photo = nil
            isProcessing = false
        }
    }

    @MainActor
    private func applySelectedImage(_ imageData: Data) {
        self.imageData = imageData
        imageBeforeBackgroundRemoval = nil
        isImageNormalized = true
        isBackgroundRemoved = false
    }

    @MainActor
    private func restoreImageBackground() {
        guard let imageBeforeBackgroundRemoval else { return }
        imageData = imageBeforeBackgroundRemoval
        self.imageBeforeBackgroundRemoval = nil
        isImageNormalized = true
        isBackgroundRemoved = false
    }

    @MainActor
    private func presentError(title: String, error: any Error) {
        NavigationCoordinator.shared.push(.init(
            title: title,
            message: "같은 오류가 계속 발생할 시 문의 부탁드립니다.\n** \(error.localizedDescription)",
            firstButton: .cancel(title: "확인", action: {}),
            secondButton: nil
        ))
    }
}


private enum ShoeImageEditingError: LocalizedError {
    case transferFailed

    var errorDescription: String? {
        switch self {
        case .transferFailed:
            "선택한 사진을 불러올 수 없습니다."
        }
    }
}

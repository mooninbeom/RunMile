//
//  ImageVisionManager.swift
//  Run Mile
//
//  Created by 문인범 on 5/28/25.
//

import Vision
import CoreImage
import ImageIO
import UIKit.UIImage


/**
 이미지 Vision 관련 메소드
 */
enum ImageVisionManager {
    private static let maximumInputBytes = 50 * 1024 * 1024
    private static let maximumPixelSize = 1600

    static func normalizeImage(from imageData: Data) throws -> Data {
        guard imageData.count <= maximumInputBytes,
              let source = CGImageSourceCreateWithData(imageData as CFData, nil)
        else {
            throw ImageVisionError.preprocessingFailed
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maximumPixelSize,
            kCGImageSourceShouldCacheImmediately: true
        ]

        guard let thumbnail = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw ImageVisionError.preprocessingFailed
        }

        let image = UIImage(cgImage: thumbnail)
        guard let normalizedData = image.jpegData(compressionQuality: 0.85) else {
            throw ImageVisionError.createJPEGDataFailed
        }
        return normalizedData
    }

    /// 이미지의 배경을 제거해주는 메소드(누끼)
    public static func removeImageBackground(
        from imageData: Data
    ) async throws -> Data {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let processingTask = Task.detached(priority: .userInitiated) {
            try Task.checkCancellation()
            guard let sourceImage = UIImage(data: imageData),
                  let sourceCIImage = CIImage(data: imageData)
            else {
                throw ImageVisionError.preprocessingFailed
            }

            let handler = VNImageRequestHandler(
                ciImage: sourceCIImage,
                orientation: .init(uiImageOrientation: sourceImage.imageOrientation)
            )
            try handler.perform([request])

            guard let result = request.results?.first else {
                throw ImageVisionError.noSubjectFound
            }

            let maskedImage = try result.generateMaskedImage(
                ofInstances: result.allInstances,
                from: handler,
                croppedToInstancesExtent: true
            )
            let ciImage = CIImage(cvPixelBuffer: maskedImage)
            let context = CIContext()

            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                throw ImageVisionError.createciImageFailed
            }
            guard let uiImageData = UIImage(cgImage: cgImage).pngData() else {
                throw ImageVisionError.createPNGDataFailed
            }

            try Task.checkCancellation()
            return uiImageData
        }

        return try await withTaskCancellationHandler {
            try await processingTask.value
        } onCancel: {
            request.cancel()
            processingTask.cancel()
        }
    }
}


struct VisionShoeImageProcessingService: ShoeImageProcessingService {
    func normalizeImage(from imageData: Data) async throws -> Data {
        let processingTask = Task.detached(priority: .userInitiated) {
            try Task.checkCancellation()
            let normalizedImage = try ImageVisionManager.normalizeImage(from: imageData)
            try Task.checkCancellation()
            return normalizedImage
        }

        return try await withTaskCancellationHandler {
            try await processingTask.value
        } onCancel: {
            processingTask.cancel()
        }
    }

    func removeBackground(from imageData: Data) async throws -> Data {
        try await ImageVisionManager.removeImageBackground(from: imageData)
    }
}

//
//  ImageVisionManager.swift
//  Run Mile
//
//  Created by 문인범 on 5/28/25.
//

import Vision
import CoreImage
import UIKit.UIImage


/**
 이미지 Vision 관련 메소드
 */
enum ImageVisionManager {
    /// 이미지의 배경을 제거해주는 메소드(누끼)
    public static func removeImageBackground(
        from imageData: Data
    ) async throws -> Data {
        guard let firstUIImage = UIImage(data: imageData),
              let firstCIImage = CIImage(data: imageData)
        else {
            throw ImageVisionError.preprocessingFailed
        }
        
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(
            ciImage: firstCIImage,
            orientation: .init(uiImageOrientation: firstUIImage.imageOrientation)
        )
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, any Error>) in
            Task(priority: .background) {
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let result = request.results?.first else {
                    print("No subject observations found, Return origianl one")
                    continuation.resume(throwing: ImageVisionError.noSubjectFound)
                    return
                }
                
                
                let maskedImage = try result.generateMaskedImage(
                    ofInstances: result.allInstances,
                    from: handler,
                    croppedToInstancesExtent: true
                )
                
                let ciImage = CIImage(cvPixelBuffer: maskedImage)
                
                let context = CIContext()
                guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
                    continuation.resume(throwing: ImageVisionError.createciImageFailed)
                    return
                }
                
                guard let uiImageData = UIImage(cgImage: cgImage).pngData() else {
                    continuation.resume(throwing: ImageVisionError.createPNGDataFailed)
                    return
                }
                
                continuation.resume(returning: uiImageData)
            }
        }
    }
}

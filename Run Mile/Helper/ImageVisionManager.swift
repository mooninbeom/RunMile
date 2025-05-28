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
        from image: CIImage
    ) async throws -> Data {
        let request = VNGenerateForegroundInstanceMaskRequest()
        let handler = VNImageRequestHandler(ciImage: image)
        
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Data, any Error>) in
            Task(priority: .background) {
                try handler.perform([request])
                
                guard let result = request.results?.first else {
                    print("No subject observations found, Return origianl one")
                    // TODO: Error handling
                    continuation.resume(throwing: NSError())
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
                    // TODO: Error handling
                    continuation.resume(throwing: NSError())
                    return
                }
                
                guard let uiImageData = UIImage(cgImage: cgImage).pngData() else {
                    // TODO: Error handling
                    continuation.resume(throwing: NSError())
                    return
                }
                
                continuation.resume(returning: uiImageData)
            }
        }
    }
}

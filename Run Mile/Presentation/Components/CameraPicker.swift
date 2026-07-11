//
//  CameraPicker.swift
//  Run Mile
//
//  Created by 문인범 on 4/18/25.
//

import SwiftUI
import UIKit


struct CameraPicker: UIViewControllerRepresentable {
    let onImagePicked: (Data) -> Void
    @Environment(\.dismiss) var dismiss

    init(image: Binding<Data?>) {
        self.onImagePicked = { image.wrappedValue = $0 }
    }

    init(onImagePicked: @escaping (Data) -> Void) {
        self.onImagePicked = onImagePicked
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
        ) {
            if let image = info[.originalImage] as? UIImage,
               let data = image.pngData() {
                parent.onImagePicked(data)
            }
            
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

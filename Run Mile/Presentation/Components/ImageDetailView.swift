//
//  ImageDetailView.swift
//  Run Mile
//
//  Created by 문인범 on 5/31/25.
//

import SwiftUI


struct ImageDetailView: View {
    
    let image: Data
    
    var body: some View {
        VStack {
            if let image = image.toImage() {
                image
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}

//
//  ContentView.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    let usecase = DefaultHealthDataUseCase()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
        .task {
            do {
                if try await !usecase.checkHealthAuthorization() {
                    print("Be Requested already")
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}

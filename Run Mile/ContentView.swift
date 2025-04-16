//
//  ContentView.swift
//  Run Mile
//
//  Created by 문인범 on 4/15/25.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        VStack {
            SampleView()
        }
    }
}



struct SampleView: View {
    let usecase = DefaultHealthDataUseCase(
        workoutDataRepository: WorkoutDataRepositoryImpl()
    )
    
    @State private var data: [RunningData] = []
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(data) { running in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .foregroundStyle(.cyan)
                            .frame(height: 50)
                        
                        VStack {
                            Text(running.id.uuidString)
                            Text(running.date?.description ?? "알 수 없음")
                            Text(running.distance.description)
                        }
                    }
                    .padding()
                }
            }
            .task {
                if try! await usecase.checkHealthAuthorization() {
                    
                }
                data = try! await usecase.fetchWorkoutData()
            }
        }
    }
}

#Preview {
    ContentView()
}

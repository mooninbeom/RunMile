//
//  SheetNavigationBar.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI


struct SheetNavigationBar: View {
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Text("신발 추가")
                .font(FontStyle.cellDistance())
            Spacer()
        }
        .overlay(alignment: .leading) {
            Button("취소") {
                action()
            }
        }
        .padding(.top, 20)
    }
}

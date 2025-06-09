//
//  InformationView.swift
//  Run Mile
//
//  Created by 문인범 on 5/3/25.
//

import SwiftUI


struct InformationView: View {
    let viewModel: InformationViewModel = .init()
    
    var body: some View {
        VStack {
            Image(.memoji)
                .resizable()
                .frame(width: 153, height: 153)
            
            Text("Mooni(문인범)")
                .font(FontStyle.placeholder())
            Text("지구 최고의 iOS 개발자가 되기 위해\n노력중인 남자")
                .font(FontStyle.cellSubtitle())
                .multilineTextAlignment(.center)
            
            VStack(alignment: .leading) {
                Button {
                    viewModel.mailButtonTapped()
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "envelope")
                            .font(.system(size: 16))
                            .foregroundStyle(.white)
                        Text(verbatim: "dlsqja567@naver.com")
                            .font(FontStyle.shoeName())
                    }
                }
                
                Link(destination: URL(string: "https://github.com/mooninbeom")!) {
                    HStack(spacing: 5) {
                        Image(.github)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("@mooninbeom")
                            .font(FontStyle.shoeName())
                    }
                }
                .offset(x: 2)
                
                Link(destination: URL(string: "https://www.linkedin.com/in/인범-문-94ba63298")!) {
                    HStack(spacing: 5) {
                        Image(.linkedIn)
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("@문인범")
                            .font(FontStyle.shoeName())
                    }
                }
                .offset(x: 2)
            }
            .padding(.top, 5)
        }
        .navigationTitle("개발자 정보")
    }
}

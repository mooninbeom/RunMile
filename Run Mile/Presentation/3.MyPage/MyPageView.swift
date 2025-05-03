//
//  MyPageView.swift
//  Run Mile
//
//  Created by 문인범 on 4/16/25.
//

import SwiftUI


struct MyPageView: View {
    @State private var viewModel: MyPageViewModel = .init(
        useCase: DefaultMyPageUseCase()
    )
    
    var body: some View {
        VStack(spacing: 0) {
            HallOfFameCell {
                viewModel.HOFButtonTapped()
            }
                .padding(.bottom, 40)
            
            ForEach(MyPageViewModel.MyPageStatus.allCases, id: \.self) { status in
                MyPageCell(status: status) {
                    viewModel.myPageCellTapped(status)
                }
                .padding(.bottom, 20)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .sheet(isPresented: $viewModel.isContactPresented) {
            ContactView()
        }
    }
}


private struct HallOfFameCell: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.hallOfFame1)
                .frame(height: 115)
                .overlay {
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            Image(systemName: "laurel.leading")
                            Image(systemName: "trophy")
                            Image(systemName: "laurel.trailing")
                        }
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        Spacer()
                        
                        Text("Hall of Fame")
                            .font(FontStyle.hallOfFame())
                            .foregroundStyle(.white)
                    }
                    .padding(.vertical, 15)
                }
                .overlay(alignment: .trailing) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .padding(15)
                }
        }
    }
}




private struct MyPageCell: View {
    let status: MyPageViewModel.MyPageStatus
    
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(.workoutCell)
                .frame(height: 70)
                .overlay {
                    HStack {
                        Text(status.cellName)
                            .font(FontStyle.myPageCell())
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 20))
                    }
                    .foregroundStyle(.white)
                    .padding(15)
                }
        }
    }
}


#Preview {
    MyPageView()
}

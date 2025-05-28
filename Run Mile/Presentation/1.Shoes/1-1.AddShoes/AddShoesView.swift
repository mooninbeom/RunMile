//
//  AddShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI
import PhotosUI


struct AddShoesView: View {
    @State private var viewModel: AddShoesViewModel = .init(
        useCase: DefaultAddShoesUseCase(
            repository: ShoesDataRepositoryImpl()
        )
    )
    
    var body: some View {
        VStack(spacing: 0) {
            SheetNavigationBar {
                viewModel.cancelButtonTapped()
            }
            
            CustomPhotoPicker(viewModel: viewModel)
            
            Button(viewModel.isImageBackgroundRemoved ? "취소" : "배경 제거") {
                viewModel.removeBackgroundButtonTapped()
            }
            .disabled(viewModel.image == nil)
            
            ShoeInfoTextField(category: .name, text: $viewModel.name)
                .padding(.vertical, 10)
            ShoeInfoTextField(category: .nickname, text: $viewModel.nickname)
                .padding(.vertical, 10)
            ShoeInfoTextField(category: .goalMileage, text: $viewModel.goalMileage)
                .padding(.vertical, 10)
            ShoeInfoTextField(category: .runMileage, text: $viewModel.runMileage)
                .padding(.vertical, 10)
            
            Spacer()

            CompleteButton(
                viewModel: viewModel,
                action: viewModel.saveButtonTapped
            )
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
        }
        .padding(.horizontal, 20)
    }
}


private struct CustomPhotoPicker: View {
    @Bindable var viewModel: AddShoesViewModel
    
    var body: some View {
        Group {
            if let image = viewModel.image,
               let uiImage = UIImage(data: image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else {
                RoundedRectangle(cornerRadius: 15)
                    .overlay {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundStyle(.primary2)
                    }
                    .foregroundStyle(.workoutCell)
            }
            
            
        }
        .frame(width: 170, height: 170)
        .padding(.vertical, 20)
        .onTapGesture {
            viewModel.imageButtonTapped()
        }
        .confirmationDialog(
            "사진 선택",
            isPresented: $viewModel.isPhotoSheetPresented
        ) {
            Button("사진 찍기", role: .none, action: viewModel.cameraButtonTapped)
            Button("앨범에서 선택", role: .none, action: viewModel.photoPickerButtonTapped)
            Button("취소", role: .cancel, action: {})
        }
        .photosPicker(
            isPresented: $viewModel.isPhotosPickerPresented,
            selection: $viewModel.photos,
            matching: .images
        )
        .fullScreenCover(isPresented: $viewModel.isCameraPresented) {
            CameraPicker(image: $viewModel.image)
        }
    }
}


private struct ShoeInfoTextField: View {
    let category: AddShoesViewModel.TextFieldCategory
    
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                TextField(category.placeholder, text: $text)
                    .font(FontStyle.placeholder())
                    .keyboardType(
                        (category == .goalMileage || category == .runMileage) ? .numberPad : .default
                    )
                
                switch category {
                case .name:
                    Text("\(text.count) / 30")
                        .font(FontStyle.kilometer())
                case .nickname:
                    Text("\(text.count) / 15")
                        .font(FontStyle.kilometer())
                case .goalMileage, .runMileage:
                    Text("km")
                        .font(FontStyle.kilometer())
                }
            }
            .padding(.bottom, 5)
            
            if category == .runMileage {
                Rectangle()
                    .foregroundStyle(.hallOfFame3)
                    .frame(height: 2)
            } else {
                Rectangle()
                    .foregroundStyle( text.isEmpty ? .primary2 : .hallOfFame3 )
                    .frame(height: 2)
            }
            
            Text("신발의 기존 마일리지가 있는 경우 기입해주세요!")
                .font(FontStyle.miniPlaceholder())
                .foregroundStyle(.placeholder1)
                .opacity( category == .runMileage ? 1 : 0)
        }
        .onChange(of: text) {
            switch category {
            case .name:
                text = text.count > 30 ? String(text.prefix(30)) : text
            case .nickname:
                text = text.count > 15 ? String(text.prefix(15)) : text
            default:
                if text.isEmpty { return }
                let isNumber = text.allSatisfy{ "0123456789".contains($0) }
                if isNumber {
                    let num = Int(text)!
                    if num > 1000 {
                        text = "1000"
                    } else {
                        text = "\(num)"
                    }
                } else {
                    text.removeAll()
                }
            }
        }
    }
}


private struct CompleteButton: View {
    @Bindable var viewModel: AddShoesViewModel
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle( viewModel.isCompleteButtonAccessible ? .primary1 : .workoutCell)
                .frame(height: 50)
                .overlay {
                    Text("등록")
                        .font(FontStyle.button())
                        .foregroundStyle(.white)
                }
        }
        .disabled(!viewModel.isCompleteButtonAccessible)
    }
}


#Preview {
    AddShoesView()
}

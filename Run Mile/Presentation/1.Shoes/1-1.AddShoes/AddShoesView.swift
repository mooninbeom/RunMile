//
//  AddShoesView.swift
//  Run Mile
//
//  Created by 문인범 on 4/17/25.
//

import SwiftUI
import PhotosUI


struct AddShoesView: View {
    @State private var viewModel: AddShoesViewModel
    
    @FocusState private var focusedField: AddShoesViewModel.TextFieldCategory?
    
    let dismissAction: () -> Void
    
    init(
        viewModel: AddShoesViewModel,
        dismissAction: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.dismissAction = dismissAction
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: - Photo Picker
                    VStack(spacing: 12) {
                        if let data = viewModel.image, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 160, height: 160)
                                .clipShape(RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous))
                                .runMileBrutalCard(cornerRadius: RunMileRadius.image)
                                .overlay(alignment: .topTrailing) {
                                    // 배경 제거 버튼 (이미지가 있을 때만)
                                    Button {
                                        viewModel.removeBackgroundButtonTapped()
                                    } label: {
                                        Image(systemName: viewModel.isImageBackgroundRemoved ? "eraser.fill" : "eraser")
                                            .foregroundStyle(.white)
                                            .padding(8)
                                            .background(Color.black.opacity(0.6))
                                            .clipShape(Circle())
                                    }
                                    .padding(8)
                                }
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                                    .fill(RunMileColor.muted)
                                    .frame(width: 160, height: 160)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: RunMileRadius.image, style: .continuous)
                                            .strokeBorder(style: StrokeStyle(lineWidth: RunMileStroke.border, dash: [6]))
                                            .foregroundStyle(RunMileColor.border)
                                    )
                                
                                VStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(RunMileColor.foreground)
                                    Text("신발 사진 등록")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(RunMileColor.foreground)
                                }
                            }
                        }
                        
                        // 통합 사진 선택 버튼 (카메라/앨범 선택 다이얼로그 호출)
                        Button {
                            viewModel.imageButtonTapped()
                        } label: {
                            Text(viewModel.image == nil ? "사진 선택" : "사진 변경")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(RunMileColor.secondaryForeground)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background {
                                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                                        .fill(RunMileColor.secondary)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                                        .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                                }
                        }
                    }
                    .padding(.top, 30)
                    
                    // MARK: - Input Fields
                    VStack(spacing: 20) {
                        // Brand Picker
                        inputGroup(title: "브랜드", icon: "tag.fill") {
                            Picker("브랜드를 선택해주세요", selection: $viewModel.selectedBrand) {
                                ForEach(viewModel.brandList, id: \.self) { brand in
                                    Text(brand).tag(brand)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(RunMileColor.foreground)
                            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                            .padding(.horizontal, 14)
                            .background {
                                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                                    .fill(RunMileColor.card)
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                                    .stroke(RunMileColor.input, lineWidth: RunMileStroke.border)
                            }
                        }
                        
                        // Model Picker
                        if viewModel.selectedBrand != "기타" {
                            inputGroup(title: "모델명", icon: "shoe.fill") {
                                Picker("모델을 선택해주세요", selection: $viewModel.selectedModel) {
                                    ForEach(viewModel.modelList, id: \.self) { model in
                                        Text(model).tag(model)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(RunMileColor.foreground)
                                .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
                                .padding(.horizontal, 14)
                                .background {
                                    RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                                        .fill(RunMileColor.card)
                                }
                                .overlay {
                                    RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                                        .stroke(RunMileColor.input, lineWidth: RunMileStroke.border)
                                }
                            }
                        }
                        
                        // Manual Input (If 'Etc' selected)
                        if viewModel.selectedBrand == "기타" || viewModel.selectedModel == "기타" {
                            VStack(spacing: 12) {
                                if viewModel.selectedBrand == "기타" {
                                    AddShoesTextField(title: "브랜드 직접 입력", text: $viewModel.customBrand, focusState: $focusedField, category: .customBrand)
                                }
                                if viewModel.selectedBrand == "기타" || viewModel.selectedModel == "기타" {
                                    AddShoesTextField(title: "모델명 직접 입력", text: $viewModel.customModel, focusState: $focusedField, category: .customModel)
                                }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Usage Input
                        AddShoesTextField(title: "용도 (예: 대회용, 조깅용)", text: $viewModel.usage, icon: "figure.run", maxLength: 10, focusState: $focusedField, category: .usage)
                        
                        // Goal Mileage Input
                        AddShoesTextField(title: "목표 마일리지 (km)", text: $viewModel.goalMileage, icon: "flag.checkered", keyboardType: .numberPad, maxLength: nil, maxMileage: 2000, focusState: $focusedField, category: .goalMileage)
                    }
                    .padding(.horizontal)
                    
                    
                    // MARK: - Complete Button
                    Button {
                        viewModel.saveButtonTapped()
                    } label: {
                        Text("신발 등록하기")
                            .runMilePrimaryButton(isEnabled: viewModel.isCompleteButtonAccessible)
                    }
                    .disabled(!viewModel.isCompleteButtonAccessible)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .navigationTitle("신발 추가")
            .navigationBarTitleDisplayMode(.inline)
            .background(RunMileColor.background)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        viewModel.cancelButtonTapped()
                    }
                    .foregroundStyle(RunMileColor.primary)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    HStack {
                        Button {
                            viewModel.keyboardToolbarUpButtonTapped(&focusedField)
                        } label: {
                            Image(systemName: "chevron.up")
                        }
                        .disabled(focusedField?.previous(viewModel: viewModel) == nil)
                        
                        Button {
                            viewModel.keyboardToolbarDownButtonTapped(&focusedField)
                        } label: {
                            Image(systemName: "chevron.down")
                        }
                        .disabled(focusedField?.next(viewModel: viewModel) == nil)
                        
                        Spacer()
                        
                        Button("완료") {
                            viewModel.keyboardToolbarCompleteButtonTapped(&focusedField)
                        }
                    }
                }
            }
        }
        .onDisappear {
            dismissAction()
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
    
    // Helper View Builder
    private func inputGroup<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(RunMileColor.mutedForeground)
            
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


// Custom TextField Component
private struct AddShoesTextField: View {
    let title: String
    @Binding var text: String
    var icon: String? = nil
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int? = nil
    var maxMileage: Int? = nil
    var focusState: FocusState<AddShoesViewModel.TextFieldCategory?>.Binding
    let category: AddShoesViewModel.TextFieldCategory
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                if let icon {
                    Label(title, systemImage: icon)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.mutedForeground)
                } else {
                    Text(title)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
                
                Spacer()
                
                if let maxLength {
                    Text("\(text.count) / \(maxLength)")
                        .font(.caption2)
                        .foregroundStyle(text.count > maxLength ? RunMileColor.primary : RunMileColor.mutedForeground)
                }
                
                if let maxMileage {
                    Text("최대 \(maxMileage)km")
                        .font(.caption2)
                        .foregroundStyle(RunMileColor.mutedForeground)
                }
            }
            
            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(title)
                        .foregroundStyle(RunMileColor.mutedForeground.opacity(0.7))
                }

                TextField("", text: $text)
                    .foregroundStyle(RunMileColor.foreground)
            }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                        .fill(RunMileColor.card)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                        .stroke(RunMileColor.input, lineWidth: RunMileStroke.border)
                }
                .keyboardType(keyboardType)
                .focused(focusState, equals: category)
                .onChange(of: text) { _, newValue in
                    // Character Limit
                    if let maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                    
                    // Max Mileage Limit
                    if let maxMileage, let num = Int(newValue) {
                        if num > maxMileage {
                            text = String(maxMileage)
                        }
                    }
                }
        }
    }
}

#Preview {
    AddShoesView(
        viewModel: AppDIContainer().makeAddShoesViewModel(),
        dismissAction: {}
    )
}

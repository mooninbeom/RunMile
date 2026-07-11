//
//  ShoesEditSheetView.swift
//  Run Mile
//
//  Created by Codex on 5/8/26.
//

import SwiftUI
import PhotosUI
import UIKit


struct ShoesEditSheetView: View {
    @Bindable var imageEditorViewModel: ShoeImageEditorViewModel
    @Binding var brand: String
    @Binding var model: String
    @Binding var customBrand: String
    @Binding var customModel: String
    @Binding var usage: String
    @Binding var goalMileage: String
    let brandList: [String]
    let modelList: [String]
    let isDoneEnabled: Bool
    let onCancel: () -> Void
    let onDone: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    headerView
                    ShoeImageEditorView(
                        imageData: imageEditorViewModel.imageData,
                        isBackgroundRemoved: imageEditorViewModel.isBackgroundRemoved,
                        isProcessing: imageEditorViewModel.isProcessing,
                        onChangePhoto: imageEditorViewModel.photoButtonTapped,
                        onRemoveBackground: imageEditorViewModel.backgroundButtonTapped
                    )
                    inputFieldsView
                    recommendedMileageView
                    doneButton
                }
                .padding(20)
            }
            .background(RunMileColor.background)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기", action: onCancel)
                        .foregroundStyle(RunMileColor.primary)
                }
            }
        }
        .confirmationDialog(
            "사진 선택",
            isPresented: $imageEditorViewModel.isPhotoSourcePresented
        ) {
            Button("사진 찍기", action: imageEditorViewModel.cameraButtonTapped)
                .disabled(!UIImagePickerController.isSourceTypeAvailable(.camera))
            Button("앨범에서 선택", action: imageEditorViewModel.photoLibraryButtonTapped)
            Button("취소", role: .cancel, action: {})
        }
        .photosPicker(
            isPresented: $imageEditorViewModel.isPhotoPickerPresented,
            selection: $imageEditorViewModel.photo,
            matching: .images
        )
        .fullScreenCover(isPresented: $imageEditorViewModel.isCameraPresented) {
            CameraPicker(onImagePicked: imageEditorViewModel.cameraImagePicked)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("신발 정보 수정")
                .font(.title2.weight(.black))
                .foregroundStyle(RunMileColor.foreground)
            
            Text("사진과 신발 정보를 함께 관리합니다.")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(RunMileColor.mutedForeground)
        }
    }
    
    private var inputFieldsView: some View {
        VStack(spacing: 16) {
            ShoesEditPickerField(
                title: "브랜드",
                icon: "tag.fill",
                selection: $brand,
                items: brandList,
                placeholder: "브랜드를 선택해주세요"
            )
            
            if brand != ShoeCatalog.other {
                ShoesEditPickerField(
                    title: "모델명",
                    icon: "shoe.fill",
                    selection: $model,
                    items: modelList,
                    placeholder: "모델을 선택해주세요"
                )
            }
            
            if brand == ShoeCatalog.other || model == ShoeCatalog.other {
                customInputFieldsView
            }
            
            ShoesEditField(title: "용도", icon: "figure.run", text: $usage, maxLength: 10)
            ShoesEditField(title: "목표 마일리지 (km)", icon: "flag.checkered", text: $goalMileage, keyboardType: .numberPad)
        }
    }
    
    private var customInputFieldsView: some View {
        VStack(spacing: 12) {
            if brand == ShoeCatalog.other {
                ShoesEditField(title: "브랜드 직접 입력", icon: "tag.fill", text: $customBrand)
            }
            
            ShoesEditField(title: "모델명 직접 입력", icon: "shoe.fill", text: $customModel)
        }
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var recommendedMileageView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("추천 목표", systemImage: "sparkles")
                .font(.caption.weight(.bold))
                .foregroundStyle(RunMileColor.mutedForeground)
            
            HStack(spacing: 8) {
                ForEach(["300", "500", "700", "1000"], id: \.self) { mileage in
                    Button {
                        goalMileage = mileage
                    } label: {
                        Text("\(mileage)km")
                            .font(.caption.weight(.black))
                            .foregroundStyle(goalMileage == mileage ? RunMileColor.secondaryForeground : RunMileColor.foreground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(goalMileage == mileage ? RunMileColor.secondary : RunMileColor.card)
                            .overlay {
                                RoundedRectangle(cornerRadius: RunMileRadius.button, style: .continuous)
                                    .stroke(RunMileColor.border, lineWidth: RunMileStroke.border)
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var doneButton: some View {
        Button(action: onDone) {
            Text("수정 완료")
                .runMilePrimaryButton(isEnabled: isDoneEnabled)
        }
        .disabled(!isDoneEnabled)
    }
}


private struct ShoesEditPickerField: View {
    let title: String
    let icon: String
    @Binding var selection: String
    let items: [String]
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(RunMileColor.mutedForeground)
            
            Picker(placeholder, selection: $selection) {
                ForEach(items, id: \.self) { item in
                    Text(item).tag(item)
                }
            }
            .pickerStyle(.menu)
            .tint(RunMileColor.foreground)
            .frame(maxWidth: .infinity, minHeight: 52, alignment: .leading)
            .padding(.horizontal, 14)
            .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                    .stroke(RunMileColor.input, lineWidth: RunMileStroke.border)
            }
        }
    }
}


private struct ShoesEditField: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var maxLength: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(RunMileColor.mutedForeground)
                
                Spacer()
                
                if let maxLength {
                    Text("\(text.count) / \(maxLength)")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(text.count > maxLength ? RunMileColor.primary : RunMileColor.mutedForeground)
                }
            }
            
            TextField(title, text: $text)
                .font(.body.weight(.semibold))
                .foregroundStyle(RunMileColor.foreground)
                .padding()
                .background(RunMileColor.card, in: RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: RunMileRadius.input, style: .continuous)
                        .stroke(RunMileColor.input, lineWidth: RunMileStroke.border)
                }
                .keyboardType(keyboardType)
                .onChange(of: text) { _, newValue in
                    if let maxLength, newValue.count > maxLength {
                        text = String(newValue.prefix(maxLength))
                    }
                }
        }
    }
}

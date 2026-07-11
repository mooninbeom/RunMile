import Foundation


extension AddShoesViewModel {
    enum TextFieldCategory: Hashable {
        case customBrand
        case customModel
        case usage
        case goalMileage

        @MainActor
        func previous(viewModel: AddShoesViewModel) -> TextFieldCategory? {
            switch self {
            case .customBrand:
                return nil
            case .customModel:
                return viewModel.selectedBrand == ShoeCatalog.other ? .customBrand : nil
            case .usage:
                if viewModel.selectedBrand == ShoeCatalog.other || viewModel.selectedModel == ShoeCatalog.other {
                    return .customModel
                }
                return nil
            case .goalMileage:
                return .usage
            }
        }

        @MainActor
        func next(viewModel: AddShoesViewModel) -> TextFieldCategory? {
            switch self {
            case .customBrand:
                return .customModel
            case .customModel:
                return .usage
            case .usage:
                return .goalMileage
            case .goalMileage:
                return nil
            }
        }
    }

    func keyboardToolbarUpButtonTapped(_ textField: inout TextFieldCategory?) {
        guard let current = textField else { return }
        textField = current.previous(viewModel: self) ?? textField
    }

    func keyboardToolbarDownButtonTapped(_ textField: inout TextFieldCategory?) {
        guard let current = textField else { return }
        textField = current.next(viewModel: self) ?? textField
    }

    func keyboardToolbarCompleteButtonTapped(_ textField: inout TextFieldCategory?) {
        textField = nil
    }
}

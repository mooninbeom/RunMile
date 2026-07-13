#if DEBUG
import SwiftUI


struct AppUpdateFlowPreviewView: View {
    @State private var navigationCoordinator = NavigationCoordinator.shared

    private let container: PreviewDIContainer
    private let viewModel: ShoesListViewModel

    init() {
        let container = PreviewDIContainer()
        self.container = container
        self.viewModel = container.makeShoesListViewModel()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            NavigationStack {
                ShoesListView(viewModel: viewModel)
            }

            if case let .appUpdate(info)? = navigationCoordinator.customSheet {
                RunMileColor.scrim
                    .ignoresSafeArea()
                    .onTapGesture(perform: navigationCoordinator.dismissCustomSheet)

                VStack(spacing: 0) {
                    AppUpdateDetailSheet(
                        viewModel: container.makeAppUpdateDetailSheetViewModel(
                            info: info,
                            dismissAction: navigationCoordinator.dismissCustomSheet
                        )
                    )
                }
                .geometryGroup()
                .transition(.move(edge: .bottom))
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .animation(
            .spring(response: 0.42, dampingFraction: 0.88),
            value: navigationCoordinator.customSheet != nil
        )
        .onAppear(perform: navigationCoordinator.dismissCustomSheet)
        .onDisappear(perform: navigationCoordinator.dismissCustomSheet)
    }
}


#Preview("App Update Flow") {
    AppUpdateFlowPreviewView()
}
#endif

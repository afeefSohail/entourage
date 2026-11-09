import SwiftUI

struct RootRouter: View {
    @State private var appState = AppState()

    var body: some View {
        SwiftUI.Group {
            switch appState.phase {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingView()
            case .main:
                AppRootView()
            }
        }
        .environment(appState)
        .animation(.easeInOut(duration: 0.3), value: appState.phase == .main)
    }
}

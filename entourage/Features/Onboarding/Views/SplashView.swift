import SwiftUI
import Contacts

struct SplashView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        ZStack {
            Color("themeColor").ignoresSafeArea()
            Image("entourage_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 160)
        }
        .task { await resolveInitialRoute() }
    }

    private func resolveInitialRoute() async {
        guard !User.needsLogin() else {
            appState.initialOnboardingStep = .tutorial
            appState.phase = .onboarding
            return
        }

        do {
            let user = try await fetchUser()

            if user.isBlocked == true {
                appState.initialOnboardingStep = .banned(username: user.user_name ?? "")
                appState.phase = .onboarding
                return
            }

            let appDelegate = await UIApplication.shared.delegate as? AppDelegate
            await appDelegate?.setUpFireBaseConfig()

            switch user.checkUserInfo() {
            case "Gender":
                appState.initialOnboardingStep = .gender
                appState.phase = .onboarding
            case "Photos":
                appState.initialOnboardingStep = .photos
                appState.phase = .onboarding
            case "userName":
                appState.initialOnboardingStep = .username
                appState.phase = .onboarding
            default:
                let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
                if contactStatus != .authorized {
                    appState.initialOnboardingStep = .contactsPermission
                    appState.phase = .onboarding
                } else {
                    appState.phase = .main
                }
            }
        } catch {
            appState.initialOnboardingStep = .tutorial
            appState.phase = .onboarding
        }
    }

    private func fetchUser() async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            WebServicesManager.shared.getUser { user, error in
                if let error {
                    continuation.resume(throwing: NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: error]))
                } else if let user = user as? User {
                    continuation.resume(returning: user)
                } else {
                    continuation.resume(throwing: NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Unknown error"]))
                }
            }
        }
    }
}

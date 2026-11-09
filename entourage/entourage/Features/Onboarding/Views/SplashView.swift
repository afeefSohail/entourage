import SwiftUI
import Contacts
import CoreLocation

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

            // Load settings in background — populates EntourageManager.shared.setting
            Task { _ = try? await UserRepository.shared.getUserSettings() }

            switch user.nextProfileStep {
            case .age:
                appState.initialOnboardingStep = .gender
                appState.phase = .onboarding
            case .photos:
                appState.initialOnboardingStep = .photos
                appState.phase = .onboarding
            case .username:
                appState.initialOnboardingStep = .username
                appState.phase = .onboarding
            case .complete:
                let contactStatus = CNContactStore.authorizationStatus(for: .contacts)
                if contactStatus != .authorized {
                    appState.initialOnboardingStep = .contactsPermission
                    appState.phase = .onboarding
                } else {
                    let locationStatus = CLLocationManager.authorizationStatus()
                    if locationStatus == .notDetermined {
                        appState.initialOnboardingStep = .locationPermission
                        appState.phase = .onboarding
                    } else {
                        // Update coordinates in background on every launch
                        Task {
                            await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
                                UserRepository.shared.updateLocation { _, _ in cont.resume() }
                            }
                        }
                        appState.phase = .main
                    }
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

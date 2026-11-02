import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @State private var coordinator = OnboardingCoordinator()

    var body: some View {
        NavigationStack(path: Bindable(coordinator).path) {
            destinationView(for: appState.initialOnboardingStep)
                .navigationDestination(for: OnboardingStep.self) { step in
                    destinationView(for: step)
                }
        }
        .environment(coordinator)
    }

    @ViewBuilder
    private func destinationView(for step: OnboardingStep) -> some View {
        switch step {
        case .tutorial:             TutorialView()
        case .phoneInput:           PhoneInputView()
        case .otp(let phone):       OTPView(phone: phone)
        case .gender:               GenderView()
        case .firstName:            NameView(isLastName: false)
        case .lastName:             NameView(isLastName: true)
        case .birthday:             BirthdayView()
        case .photos:               PhotosView()
        case .username:             UsernameView()
        case .contactsPermission:   ContactsPermissionView()
        case .addFriends:           OnboardingAddFriendsView()
        case .banned(let name):     UserBannedView(username: name)
        }
    }
}

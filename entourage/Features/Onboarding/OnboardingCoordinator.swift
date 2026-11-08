import SwiftUI

enum OnboardingStep: Hashable {
    case tutorial
    case phoneInput
    case otp(phone: String)
    case gender
    case firstName
    case lastName
    case birthday
    case photos
    case username
    case contactsPermission
    case locationPermission
    case notificationPermission
    case addFriends
    case banned(username: String)
}

@Observable
@MainActor
final class OnboardingCoordinator {
    var path = NavigationPath()

    func push(_ step: OnboardingStep) { path.append(step) }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() { path = NavigationPath() }
}

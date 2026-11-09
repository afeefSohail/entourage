import SwiftUI

@Observable
final class AppState {
    enum Phase {
        case splash
        case onboarding
        case main
    }

    var phase: Phase = .splash
    var initialOnboardingStep: OnboardingStep = .tutorial
}

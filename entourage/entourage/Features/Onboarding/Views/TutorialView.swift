import SwiftUI

struct TutorialView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image("tutorial_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220)
                    .padding(.bottom, 32)

                Text("Meet people.\nSwipe together.")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 12)

                Text("Find your group, make connections,\nand swipe with friends.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()

                Button {
                    coordinator.push(.phoneInput)
                } label: {
                    Text("Continue with Phone Number")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color("themeColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

                privacyText
                    .padding(.horizontal, 24)
                    .padding(.bottom, 32)
            }
        }
        .navigationBarHidden(true)
    }

    private var privacyText: some View {
        let full = "By continuing, you agree to both our\nTerms and Privacy Policy"
        return Text(full)
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .overlay(alignment: .center) {
                HStack(spacing: 0) {
                    Spacer()
                    Link("Terms", destination: URL(string: "https://www.entourage-app.com/terms-of-service.php")!)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(" and ")
                        .font(.system(size: 12))
                        .foregroundStyle(.clear)
                    Link("Privacy Policy", destination: URL(string: "https://www.entourage-app.com/privacy-policy.php")!)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                }
                .offset(y: 8)
            }
    }
}

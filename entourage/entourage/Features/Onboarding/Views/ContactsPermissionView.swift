import SwiftUI
import Contacts

struct ContactsPermissionView: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "person.2.wave.2.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("themeColor"))
                .padding(.bottom, 24)

            Text("Find friends\non Entourage")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text("Allow Entourage to access your contacts to find people you know.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                Task { await requestAccess() }
            } label: {
                ZStack {
                    Text("Allow Contacts Access")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(isRequesting ? 0 : 1)
                    if isRequesting { ProgressView().tint(.white) }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color("themeColor"))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(isRequesting)
            .padding(.horizontal, 24)
            .padding(.bottom, 12)

            Button("Maybe later") {
                coordinator.push(.locationPermission)
            }
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func requestAccess() async {
        isRequesting = true
        defer { isRequesting = false }

        let store = CNContactStore()
        _ = (try? await store.requestAccess(for: .contacts)) ?? false
        coordinator.push(.locationPermission)
    }
}

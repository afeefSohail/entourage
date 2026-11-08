import SwiftUI
import UserNotifications

struct NotificationPermissionView: View {
    @Environment(AppState.self) private var appState
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "bell.badge.fill")
                .font(.system(size: 64))
                .foregroundStyle(Color("themeColor"))
                .padding(.bottom, 24)

            Text("Stay in the loop")
                .font(.system(size: 28, weight: .bold))
                .multilineTextAlignment(.center)
                .padding(.bottom, 12)

            Text("Get notified when you match, receive messages, or someone sends you a friend request.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()

            Button {
                Task { await requestPermission() }
            } label: {
                ZStack {
                    Text("Allow Notifications")
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
                coordinator.push(.addFriends)
            }
            .font(.system(size: 14))
            .foregroundStyle(.secondary)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }

    private func requestPermission() async {
        isRequesting = true
        defer { isRequesting = false }
        PushNotificationManager.sharedInstance.registerForPushNotifications { _ in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        coordinator.push(.addFriends)
    }
}

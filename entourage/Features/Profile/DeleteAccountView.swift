import SwiftUI

struct DeleteAccountView: View {
    @Environment(AppState.self) private var appState

    @State private var selectedReason = ""
    @State private var isDeleting = false
    @State private var showConfirmation = false

    private let reasons = [
        "I found a partner",
        "It's not working for me",
        "Too many notifications",
        "Privacy concerns",
        "I'm taking a break",
        "Other"
    ]

    var body: some View {
        List {
            Section {
                ForEach(reasons, id: \.self) { reason in
                    Button {
                        selectedReason = reason
                    } label: {
                        HStack {
                            Text(reason).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: selectedReason == reason ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedReason == reason ? Color("themeColor") : .secondary)
                        }
                    }
                }
            }

            Section {
                Button {
                    showConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        if isDeleting {
                            ProgressView().tint(.white)
                        } else {
                            Text("Delete Account")
                                .foregroundStyle(.white)
                                .font(.system(size: 16, weight: .semibold))
                        }
                        Spacer()
                    }
                    .padding(.vertical, 6)
                }
                .listRowBackground(selectedReason.isEmpty ? Color.red.opacity(0.4) : Color.red)
                .disabled(selectedReason.isEmpty || isDeleting)
            }
        }
        .navigationTitle("Delete Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account?", isPresented: $showConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task { await deleteAccount() }
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }

    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }
        await withCheckedContinuation { (cont: CheckedContinuation<Void, Never>) in
            UserRepository.shared.deleteUserAccount(reason: selectedReason) { _, _ in cont.resume() }
        }
        EntourageManager.shared.user.removeToken()
        EntourageManager.shared.reSetAppData()
        appState.initialOnboardingStep = .tutorial
        appState.phase = .onboarding
    }
}

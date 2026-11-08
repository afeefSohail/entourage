import SwiftUI
import Combine

struct UsernameView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var username = ""
    @State private var status: ValidationStatus = .idle
    @State private var isLoading = false
    @FocusState private var focused: Bool

    private var canContinue: Bool {
        if case .available = status { return true }
        return false
    }

    enum ValidationStatus {
        case idle, checking, available, taken, error(String)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Pick a username")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            HStack {
                TextField("username", text: $username)
                    .font(.system(size: 16))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($focused)
                    .onChange(of: username) { _, new in
                        username = new.lowercased()
                            .replacingOccurrences(of: " ", with: "")
                        EntourageManager.shared.user.user_name = username
                        if username.count >= 3 {
                            status = .checking
                            checkUsername(username)
                        } else {
                            status = .idle
                        }
                    }

                statusIcon
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 24)
            .padding(.bottom, 8)

            statusMessage
                .padding(.horizontal, 24)

            Spacer()

            Button {
                focused = false
                Task { await saveAndContinue() }
            } label: {
                ZStack {
                    Text("Continue")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(isLoading ? 0 : 1)
                    if isLoading { ProgressView().tint(.white) }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(canContinue ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!canContinue || isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Create a Username")
        .onAppear { focused = true }
    }

    @ViewBuilder
    private var statusIcon: some View {
        switch status {
        case .idle: EmptyView()
        case .checking: ProgressView().scaleEffect(0.8)
        case .available:
            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
        case .taken, .error:
            Image(systemName: "xmark.circle.fill").foregroundStyle(.red)
        }
    }

    @ViewBuilder
    private var statusMessage: some View {
        switch status {
        case .idle: EmptyView()
        case .checking: Text("Checking availability...").font(.system(size: 12)).foregroundStyle(.secondary)
        case .available: Text("Username is available!").font(.system(size: 12)).foregroundStyle(.green)
        case .taken: Text("Username is taken.").font(.system(size: 12)).foregroundStyle(.red)
        case .error(let msg): Text(msg).font(.system(size: 12)).foregroundStyle(.red)
        }
    }

    private var debounceTask: Task<Void, Never>? = nil

    private func checkUsername(_ name: String) {
        debounceTask?.cancel()
        let task = Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await MainActor.run { status = .checking }
            do {
                try await UserRepository.shared.checkUserNameAvailability(userName: name)
                await MainActor.run { status = .available }
            } catch {
                await MainActor.run { status = .taken }
            }
        }
        _ = task
    }

    private func saveAndContinue() async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await UserRepository.shared.editUserProfile(checkAge: false)
            coordinator.push(.contactsPermission)
        } catch {
            status = .error(error.localizedDescription)
        }
    }
}

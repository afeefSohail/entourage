import SwiftUI

struct NameView: View {
    let isLastName: Bool

    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var text = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @FocusState private var focused: Bool

    private var isValid: Bool { text.count >= 3 }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(isLastName ? "What's your\nlast name?" : "What's your\nfirst name?")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(text.isEmpty ? Color(.systemGray3) : Color(.label))
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .animation(.easeInOut(duration: 0.2), value: text.isEmpty)

            TextField(isLastName ? "Last Name" : "First Name", text: $text)
                .font(.system(size: 16))
                .focused($focused)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.horizontal, 24)
                .padding(.bottom, 8)
                .onChange(of: text) { _, new in
                    if isLastName {
                        EntourageManager.shared.user.last_name = new
                    } else {
                        EntourageManager.shared.user.first_name = new
                    }
                }

            Text(isLastName ? "Only your first name will be public." : "This is how it will be displayed.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 24)

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
                    .padding(.top, 8)
            }

            Spacer()

            Button {
                focused = false
                if isLastName {
                    Task { await saveAndContinue() }
                } else {
                    coordinator.push(.lastName)
                }
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
                .background(isValid ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid || isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(isLastName ? "Last Name" : "First Name")
        .onAppear { focused = true }
    }

    private func saveAndContinue() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                WebServicesManager.shared.editUserProfile(checkAge: false) { _, error in
                    if let error { cont.resume(throwing: NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: error])) }
                    else { cont.resume(returning: ()) }
                }
            }
            coordinator.push(.birthday)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

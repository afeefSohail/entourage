import SwiftUI

struct GenderView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var selected: String? = EntourageManager.shared.user.gender
    @State private var isLoading = false
    @State private var errorMessage: String?

    private let options = [("Female", "female"), ("Male", "male"), ("Other", "other")]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What's your\ngender?")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            VStack(spacing: 12) {
                ForEach(options, id: \.1) { label, value in
                    Button {
                        selected = value
                        EntourageManager.shared.user.gender = value
                    } label: {
                        HStack {
                            Text(label)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(selected == value ? .white : Color(.label))
                            Spacer()
                            if selected == value {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                        .background(selected == value ? Color("themeColor") : Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 24)

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
            }

            Spacer()

            Button {
                Task { await saveGender() }
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
                .background(selected != nil ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(selected == nil || isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Gender")
    }

    private func saveGender() async {
        isLoading = true
        defer { isLoading = false }
        do {
            _ = try await UserRepository.shared.editUserProfile(checkAge: false)
            coordinator.push(.firstName)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

import SwiftUI
import FirebaseAuth

struct OTPView: View {
    let phone: String

    @Environment(OnboardingCoordinator.self) private var coordinator
    @Environment(AppState.self) private var appState

    @State private var code = ""
    @State private var isVerified = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var secondsLeft = 60
    @State private var timerActive = true
    @FocusState private var isFocused: Bool

    private let codeLength = 6

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Enter the code")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)
                .padding(.horizontal, 24)

            Text(maskedPhone)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .padding(.top, 8)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            otpBoxes
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
            }

            timerOrResend
                .padding(.horizontal, 24)
                .padding(.top, 8)

            Spacer()

            Button {
                Task { await submitCode() }
            } label: {
                ZStack {
                    Text("Verify")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .opacity(isLoading ? 0 : 1)
                    if isLoading { ProgressView().tint(.white) }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isVerified ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isVerified || isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { startTimer(); sendSMS() }
        .background(hiddenTextField)
    }

    // MARK: - OTP Boxes

    private var otpBoxes: some View {
        HStack(spacing: 10) {
            ForEach(0..<codeLength, id: \.self) { i in
                let char: String = i < code.count
                    ? String(code[code.index(code.startIndex, offsetBy: i)])
                    : ""
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.systemGray6))
                        .frame(height: 52)
                    Text(char.isEmpty ? "•" : char)
                        .font(.system(size: char.isEmpty ? 10 : 20, weight: .semibold))
                        .foregroundStyle(char.isEmpty ? Color(.systemGray3) : Color("themeColor"))
                }
                .onTapGesture { isFocused = true }
            }
        }
    }

    private var hiddenTextField: some View {
        TextField("", text: $code)
            .keyboardType(.numberPad)
            .opacity(0)
            .frame(width: 1, height: 1)
            .focused($isFocused)
            .onChange(of: code) { _, new in
                let filtered = String(new.filter(\.isNumber).prefix(codeLength))
                if filtered != new { code = filtered }
                errorMessage = nil
                if filtered.count == codeLength { Task { await verifyCode(filtered) } }
                isVerified = false
            }
            .onAppear { isFocused = true }
    }

    // MARK: - Timer

    @ViewBuilder private var timerOrResend: some View {
        if timerActive {
            Text("Send again \(secondsLeft)s")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        } else {
            Button("Resend code") {
                code = ""
                isVerified = false
                errorMessage = nil
                secondsLeft = 60
                timerActive = true
                sendSMS()
                startTimer()
            }
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color("themeColor"))
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if secondsLeft > 0 {
                secondsLeft -= 1
            } else {
                timerActive = false
                timer.invalidate()
            }
        }
    }

    // MARK: - Firebase

    private func sendSMS() {
        FireBaseAuth.phoneVerificationWith(phoneNumber: phone) { _, _ in }
    }

    private func verifyCode(_ entered: String) async {
        let credential = FireBaseAuth.getCredentialWith(
            verificationID: FireBaseAuth.verificationId,
            verificationCode: entered
        )
        FireBaseAuth.SignInWith(credential: credential) { success, error in
            if error == nil {
                isVerified = true
                errorMessage = nil
            } else {
                isVerified = false
                errorMessage = "Incorrect code. Try again."
            }
        }
    }

    private func submitCode() async {
        guard isVerified else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let user = try await signUpOrGetUser()
            await handlePostVerification(user: user)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func signUpOrGetUser() async throws -> User {
        do {
            guard let u = try await UserRepository.shared.userSignUp(phoneNum: phone) else {
                throw RepositoryError(message: "Unknown error")
            }
            return u
        } catch let err as RepositoryError where err.message == "phone number already exist." {
            guard let u = try await UserRepository.shared.getUserBy(phoneNum: phone) else {
                throw RepositoryError(message: "Unknown error")
            }
            return u
        }
    }

    @MainActor
    private func handlePostVerification(user: User) async {
        if user.isBlocked == true {
            coordinator.push(.banned(username: user.userName ?? ""))
            return
        }
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.setUpFireBaseConfig()

        switch user.nextProfileStep {
        case .gender:   coordinator.push(.gender)
        case .name:     coordinator.push(.firstName)
        case .birthday: coordinator.push(.birthday)
        case .photos:   coordinator.push(.photos)
        case .username: coordinator.push(.username)
        case .complete:
            let status = CNContactStore.authorizationStatus(for: .contacts)
            if status == .authorized {
                appState.phase = .main
            } else {
                coordinator.push(.contactsPermission)
            }
        }
    }

    private var maskedPhone: String {
        guard phone.count > 9 else { return phone }
        let start = phone.index(phone.startIndex, offsetBy: 5)
        let end = phone.index(phone.endIndex, offsetBy: -4)
        let stars = String(repeating: "•", count: phone.distance(from: start, to: end))
        return phone.replacingCharacters(in: start..<end, with: stars)
    }
}

import Contacts

import SwiftUI
import FlagPhoneNumber

// MARK: - FlagPhoneNumber UIViewRepresentable

struct FPNTextFieldRepresentable: UIViewRepresentable {
    @Binding var phoneNumber: String
    @Binding var isValid: Bool
    @Binding var countryCode: String
    @Binding var pendingCountry: FPNCountry?
    var onCountryPickerRequested: (FPNCountryRepository) -> Void

    func makeUIView(context: Context) -> FPNTextField {
        let tf = FPNTextField()
        tf.hasPhoneNumberExample = false
        tf.placeholder = "Enter your mobile number"
        tf.delegate = context.coordinator
        tf.displayMode = .list
        tf.flagButtonSize = CGSize(width: 46, height: 49)
        tf.setContentHuggingPriority(.defaultLow, for: .horizontal)
        context.coordinator.textField = tf
        return tf
    }

    func updateUIView(_ uiView: FPNTextField, context: Context) {
        guard let country = pendingCountry else { return }
        uiView.setFlag(countryCode: country.code)
        DispatchQueue.main.async { pendingCountry = nil }
    }

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    final class Coordinator: NSObject, FPNTextFieldDelegate {
        var parent: FPNTextFieldRepresentable
        weak var textField: FPNTextField?
        init(_ parent: FPNTextFieldRepresentable) { self.parent = parent }

        func fpnDisplayCountryList() {
            guard let tf = textField else { return }
            parent.onCountryPickerRequested(tf.countryRepository)
        }

        func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
            parent.countryCode = dialCode
        }

        func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
            parent.isValid = isValid
            parent.phoneNumber = textField.text ?? ""
        }
    }
}

// MARK: - Country picker sheet

struct CountryListSheet: View {
    let repository: FPNCountryRepository
    var onSelect: (FPNCountry) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredCountries: [FPNCountry] {
        guard !searchText.isEmpty else { return repository.countries }
        return repository.countries.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.phoneCode.contains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Countries")
                    .font(.system(size: 17, weight: .semibold))
                Spacer()
                Button("Done") { dismiss() }
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color("themeColor"))
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            HStack {
                Image(systemName: "magnifyingglass").foregroundStyle(.secondary)
                TextField("Search country", text: $searchText)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            Divider()

            List(filteredCountries, id: \.code.rawValue) { country in
                Button {
                    onSelect(country)
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Text(flagEmoji(for: country.code.rawValue))
                            .font(.system(size: 22))
                        Text(country.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(country.phoneCode)
                            .foregroundStyle(.secondary)
                            .font(.system(size: 14))
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private func flagEmoji(for code: String) -> String {
        code.uppercased().unicodeScalars.compactMap {
            Unicode.Scalar(127397 + $0.value)
        }.map(String.init).joined()
    }
}

// MARK: - PhoneInputView

struct PhoneInputView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var phoneNumber = ""
    @State private var countryCode = "+92"
    @State private var pendingCountry: FPNCountry?
    @State private var isValid = false
    @State private var countryRepository: FPNCountryRepository?
    @State private var showCountryPicker = false
    @State private var shakePhone = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("What's your\nphone number?")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 32)

            phoneField
                .padding(.horizontal, 24)
                .padding(.bottom, 24)

            termsText
                .padding(.horizontal, 24)

            Spacer()

            Button {
                guard isValid else { shakePhone = true; return }
                let cleaned = phoneNumber
                    .replacingOccurrences(of: "-", with: "")
                    .replacingOccurrences(of: " ", with: "")
                coordinator.push(.otp(phone: countryCode + cleaned))
            } label: {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(isValid ? Color("themeColor") : Color(.systemGray4))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showCountryPicker) {
            if let repo = countryRepository {
                CountryListSheet(repository: repo) { country in
                    pendingCountry = country
                    showCountryPicker = false
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private var phoneField: some View {
        HStack {
            FPNTextFieldRepresentable(
                phoneNumber: $phoneNumber,
                isValid: $isValid,
                countryCode: $countryCode,
                pendingCountry: $pendingCountry
            ) { repo in
                countryRepository = repo
                showCountryPicker = true
            }
            .frame(height: 52)

            if isValid {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color("themeColor"))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .modifier(ShakeModifier(trigger: shakePhone))
        .onChange(of: shakePhone) { _, new in
            if new { DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { shakePhone = false } }
        }
    }

    private var termsText: some View {
        Text("By clicking Continue I hereby agree to the ")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        + Text("Terms & Conditions")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.primary)
        + Text(" & acknowledge that I have read the ")
            .font(.system(size: 12))
            .foregroundStyle(.secondary)
        + Text("Privacy Policy.")
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(.primary)
    }
}

// MARK: - Shake animation

struct ShakeModifier: ViewModifier {
    var trigger: Bool
    @State private var offset: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .offset(x: offset)
            .onChange(of: trigger) { _, new in
                guard new else { return }
                withAnimation(.interpolatingSpring(stiffness: 600, damping: 10)) {
                    offset = -8
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.interpolatingSpring(stiffness: 600, damping: 10)) {
                        offset = 0
                    }
                }
            }
    }
}

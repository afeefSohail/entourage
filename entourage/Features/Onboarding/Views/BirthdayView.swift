import SwiftUI

struct BirthdayView: View {
    @Environment(OnboardingCoordinator.self) private var coordinator

    @State private var selectedDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
    @State private var hasPickedDate = false
    @State private var isTooYoung = false
    @State private var isLoading = false
    @State private var errorMessage: String?

    private var minAge: Int { EntourageManager.shared.setting?.min_age ?? 18 }

    private var isValid: Bool { hasPickedDate && !isTooYoung }

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMMM d, yyyy"
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("When's your\nbirthday?")
                .font(.system(size: 28, weight: .bold))
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .padding(.bottom, 16)

            if hasPickedDate {
                Text(Self.displayFormatter.string(from: selectedDate))
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(isTooYoung ? .red : Color("themeColor"))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            if isTooYoung {
                Text("You must be at least \(minAge) years old to use Entourage.")
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.system(size: 13))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 8)
            }

            DatePicker(
                "",
                selection: $selectedDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .onChange(of: selectedDate) { _, new in
                hasPickedDate = true
                EntourageManager.shared.user.dob = Int(new.timeIntervalSince1970)
                isTooYoung = !checkAgeLimit(date: new)
            }

            Spacer()

            Button {
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
                .background(isValid ? Color("themeColor") : Color(.systemGray4))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid || isLoading)
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Birthday")
    }

    private func checkAgeLimit(date: Date) -> Bool {
        let components = Calendar.current.dateComponents([.year], from: date, to: Date())
        return (components.year ?? 0) >= minAge
    }

    private func saveAndContinue() async {
        isLoading = true
        defer { isLoading = false }
        do {
            try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
                WebServicesManager.shared.editUserProfile(checkAge: true) { _, error in
                    if let error { cont.resume(throwing: NSError(domain: "", code: 0,
                        userInfo: [NSLocalizedDescriptionKey: error])) }
                    else { cont.resume(returning: ()) }
                }
            }
            coordinator.push(.photos)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

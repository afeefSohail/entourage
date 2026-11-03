import SwiftUI

enum UserAlertType {
    case block
    case unfriend
    case report

    var title: String {
        switch self {
        case .block:    return "Block User?"
        case .unfriend: return "Remove Friend?"
        case .report:   return "Report User Content"
        }
    }

    var message: String {
        switch self {
        case .block:
            return "You will no longer be able to match or view their profile including groups they're in."
        case .unfriend:
            return "You will be removed from each other's friend list."
        case .report:
            return "This user will be reported for inappropriate content or behavior."
        }
    }

    var confirmColor: Color {
        switch self {
        case .block, .unfriend: return .red
        case .report:           return Color(red: 1, green: 0.569, blue: 0)
        }
    }
}

struct UserActionAlertView: View {
    let alertType: UserAlertType
    let username: String
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()
                .onTapGesture { onCancel() }

            VStack(spacing: 16) {
                Text(username)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.secondary)

                Text(alertType.title)
                    .font(.system(size: 20, weight: .bold))

                Text(alertType.message)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                HStack(spacing: 12) {
                    Button("Cancel", action: onCancel)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color(red: 0.694, green: 0.729, blue: 0.8))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    Button("Confirm", action: onConfirm)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(alertType.confirmColor)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(24)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 32)
        }
    }
}

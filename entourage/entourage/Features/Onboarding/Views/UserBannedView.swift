import SwiftUI

struct UserBannedView: View {
    let username: String

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "exclamationmark.octagon.fill")
                .font(.system(size: 64))
                .foregroundStyle(.red)
                .padding(.bottom, 24)

            Text("@\(username)")
                .font(.system(size: 20, weight: .bold))
                .padding(.bottom, 16)

            VStack(spacing: 8) {
                Text("You have been banned from ")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                + Text("Entourage")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.secondary)
                + Text(" for activity that violates our Terms of Use.")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, 40)
            .padding(.bottom, 24)

            Link("Appeal this decision", destination: URL(string: "https://www.entourage-app.com/contact")!)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color("themeColor"))

            Spacer()
        }
        .navigationBarHidden(true)
    }
}

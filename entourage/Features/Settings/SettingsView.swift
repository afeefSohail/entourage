// SettingsView.swift — SwiftUI settings screen
import SwiftUI
import UIKit
import FirebaseAuth

struct SettingsView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @Environment(AppState.self) private var appState
    @State private var vm = SettingsViewModel()
    @State private var showLogoutAlert  = false
    @State private var showGenderAlert  = false

    var body: some View {
        List {
            // Profile
            Section {
                SettingsRow(title: "Edit Profile", icon: "person.fill") {
                    coordinator.push(.editProfile)
                }
                HStack {
                    Label("Phone", systemImage: "phone.fill")
                    Spacer()
                    Text(vm.phoneNumber).foregroundStyle(.secondary)
                }
            }

            discoverSection

            // Notifications & privacy
            Section("Privacy") {
                SettingsRow(title: "Manage Notifications", icon: "bell.fill") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                SettingsRow(title: "Blocked Users (\(vm.blockedCount))", icon: "hand.raised.fill") {
                    coordinator.push(.blockedUsers)
                }
            }

            // Legal
            Section("Legal") {
                SettingsRow(title: "Privacy Policy", icon: "lock.fill") {
                    openBrowserWith(url: "https://www.entourage-app.com/privacy-policy.php")
                }
                SettingsRow(title: "Terms of Service", icon: "doc.fill") {
                    openBrowserWith(url: "https://www.entourage-app.com/terms-of-service.php")
                }
                SettingsRow(title: "Support", icon: "questionmark.circle.fill") {
                    openBrowserWith(url: "https://www.entourage-app.com/support.php")
                }
                SettingsRow(title: "Suggest a Feature", icon: "lightbulb.fill") {
                    openBrowserWith(url: "https://entourage.upvoty.com/b/feature-requests/")
                }
            }

            // Account
            Section {
                SettingsRow(title: "Log Out", icon: "arrow.left.square.fill", role: .destructive) {
                    showLogoutAlert = true
                }
                SettingsRow(title: "Delete Account", icon: "trash.fill", role: .destructive) {
                    coordinator.push(.deleteAccount)
                }
            }

            Section {
                HStack {
                    Spacer()
                    Text(vm.buildVersion).font(.caption).foregroundStyle(.tertiary)
                    Spacer()
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if vm.isSaving {
                    ProgressView()
                } else {
                    Button("Done") {
                        Task { await vm.save(); coordinator.pop() }
                    }
                    .fontWeight(.medium)
                }
            }
        }
        .alert("Log Out?", isPresented: $showLogoutAlert) {
            Button("Log Out", role: .destructive) {
                try? Auth.auth().signOut()
                appState.phase = .onboarding
            }
            Button("Cancel", role: .cancel) {}
        }

        .alert("Change Gender", isPresented: $showGenderAlert) {
            Button("Contact Support") {
                openBrowserWith(url: "https://www.entourage-app.com/support.html")
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You can only change your Gender once in-app. Please contact us if you need to change it again.")
        }
    }
    @ViewBuilder private var discoverSection: some View {
        Section("Discover") {
            HStack {
                Label("Show Me", systemImage: "person.2.fill")
                Spacer()
                Text(vm.filterText).foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { coordinator.push(.filters) }

            HStack {
                Label("My Gender", systemImage: "figure.stand")
                Spacer()
                Text(vm.genderDisplay).foregroundStyle(.secondary)
            }
            .contentShape(Rectangle())
            .onTapGesture { showGenderAlert = true }

            ageRangeRow
            distanceRow
        }
    }

    private var ageRangeRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label("Age Range", systemImage: "calendar")
                Spacer()
                Text("\(vm.setting.min_age ?? 18)–\(vm.setting.max_age ?? 42)")
                    .foregroundStyle(.secondary)
            }
            Slider(
                value: Binding<Double>(
                    get: { Double(vm.setting.min_age ?? 18) },
                    set: { vm.setting.min_age = Int($0) }
                ),
                in: 18...70, step: 1
            ).tint(Color("themeColor"))
        }
    }

    private var distanceRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Label("Distance", systemImage: "location.fill")
                Spacer()
                Text("\(vm.setting.max_distace ?? 50) mi").foregroundStyle(.secondary)
            }
            Slider(
                value: Binding<Double>(
                    get: { Double(vm.setting.max_distace ?? 50) },
                    set: { vm.setting.max_distace = Int($0) }
                ),
                in: 1...100, step: 1
            ).tint(Color("themeColor"))
        }
    }
}

// MARK: - Helper row

struct SettingsRow: View {
    let title: String
    let icon: String
    var role: ButtonRole? = nil
    let action: () -> Void

    var body: some View {
        Button(role: role, action: action) {
            Label(title, systemImage: icon)
        }
        .foregroundStyle(role == .destructive ? .red : .primary)
    }
}


// UserProfileView.swift — SwiftUI screen for viewing another user's profile
import SwiftUI

struct UserProfileView: View {

    let user: User
    let group: Group?

    @Environment(AppCoordinator.self) private var coordinator
    @State private var friendStatus: String = ""
    @State private var isLoadingStatus = false
    @State private var isSendingRequest = false
    @State private var currentPhotoIndex = 0
    @State private var activeAlert: UserAlertType? = nil
    @State private var isPerformingAction = false
    @State private var showReportReasons = false
    @State private var selectedReportReason = ""

    private let reportReasons = ["Inappropriate behavior", "Fake profile", "Harassment", "Spam", "Other"]

    private var vm: UserViewModel { UserViewModel(user) }

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: 0) {
                    photoSection

                    VStack(alignment: .leading, spacing: 16) {
                        Text(vm.nameWithAge).font(.title2.bold())

                        friendActionSection

                        if vm.hasBio {
                            Divider()
                            Text(vm.bioText).font(.body).foregroundStyle(.secondary)
                        }

                        Divider()
                        userActionsSection

                        Spacer(minLength: 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
            }

            // Overlay alerts
            if let alertType = activeAlert {
                UserActionAlertView(
                    alertType: alertType,
                    username: vm.displayName,
                    onConfirm: { Task { await performAction(alertType) } },
                    onCancel: { activeAlert = nil }
                )
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.2), value: activeAlert != nil)
            }
        }
        .navigationTitle(vm.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadFriendStatus() }
        .sheet(isPresented: $showReportReasons) {
            reportReasonsSheet
        }
    }

    @ViewBuilder
    private var photoSection: some View {
        let sorted = user.photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        TabView(selection: $currentPhotoIndex) {
            ForEach(sorted.indices, id: \.self) { idx in
                if let urlStr = sorted[idx].medium, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color(.secondarySystemBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 360)
                    .clipped()
                    .tag(idx)
                } else {
                    Color(.secondarySystemBackground).frame(height: 360).tag(idx)
                }
            }
        }
        .tabViewStyle(.page)
        .frame(height: 360)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }

    @ViewBuilder
    private var friendActionSection: some View {
        if isLoadingStatus {
            ProgressView()
        } else {
            switch friendStatus {
            case "friend":
                Label("Friends", systemImage: "person.2.fill")
                    .foregroundStyle(.green)
                    .font(.subheadline)
            case "sent":
                Label("Request Sent", systemImage: "clock.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
            default:
                Button {
                    Task { await sendFriendRequest() }
                } label: {
                    if isSendingRequest {
                        ProgressView()
                    } else {
                        Label("Add Friend", systemImage: "person.badge.plus")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSendingRequest)
            }
        }
    }

    @ViewBuilder
    private var userActionsSection: some View {
        VStack(spacing: 0) {
            if friendStatus == "friend" {
                actionRow(
                    title: "Remove Friend",
                    icon: "person.badge.minus",
                    color: .orange
                ) {
                    activeAlert = .unfriend
                }
                Divider().padding(.leading, 44)
            }

            actionRow(
                title: "Block User",
                icon: "hand.raised.fill",
                color: .red
            ) {
                activeAlert = .block
            }
            Divider().padding(.leading, 44)

            actionRow(
                title: "Report User",
                icon: "flag.fill",
                color: Color(red: 1, green: 0.569, blue: 0)
            ) {
                showReportReasons = true
            }
        }
    }

    @ViewBuilder
    private func actionRow(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 28)
                Text(title)
                    .foregroundStyle(.primary)
                Spacer()
                if isPerformingAction {
                    ProgressView().scaleEffect(0.8)
                }
            }
            .padding(.vertical, 12)
        }
        .disabled(isPerformingAction)
    }

    @ViewBuilder
    private var reportReasonsSheet: some View {
        NavigationStack {
            List {
                ForEach(reportReasons, id: \.self) { reason in
                    Button {
                        selectedReportReason = reason
                    } label: {
                        HStack {
                            Text(reason).foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: selectedReportReason == reason ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(selectedReportReason == reason ? Color("themeColor") : .secondary)
                        }
                    }
                }
            }
            .navigationTitle("Report Reason")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showReportReasons = false; selectedReportReason = "" }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Report") {
                        showReportReasons = false
                        activeAlert = .report
                    }
                    .disabled(selectedReportReason.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func loadFriendStatus() async {
        isLoadingStatus = true
        defer { isLoadingStatus = false }
        if let status = try? await UserRepository.shared.checkUserFriendStatus(friendId: user.id) {
            friendStatus = status
        }
    }

    private func sendFriendRequest() async {
        isSendingRequest = true
        defer { isSendingRequest = false }
        if (try? await UserRepository.shared.sendRequest(friendId: user.id)) != nil {
            friendStatus = "sent"
        }
    }

    private func performAction(_ type: UserAlertType) async {
        isPerformingAction = true
        activeAlert = nil
        defer { isPerformingAction = false }
        switch type {
        case .block:
            try? await UserRepository.shared.blockFriend(friendId: user.id)
            coordinator.pop()
        case .unfriend:
            try? await UserRepository.shared.unFriend(friendId: user.id)
            friendStatus = ""
        case .report:
            try? await UserRepository.shared.reportUser(userId: user.id, reason: selectedReportReason)
            selectedReportReason = ""
        }
    }
}

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

    private var vm: UserViewModel { UserViewModel(user: user) }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Photo pager
                photoSection

                VStack(alignment: .leading, spacing: 16) {
                    // Name + age
                    Text(vm.nameWithAge).font(.title2.bold())

                    // Friend status / action
                    friendActionSection

                    // Bio
                    if vm.hasBio {
                        Divider()
                        Text(vm.bioText).font(.body).foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle(vm.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadFriendStatus() }
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
}

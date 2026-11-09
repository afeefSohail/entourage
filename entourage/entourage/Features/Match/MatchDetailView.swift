// MatchDetailView.swift — SwiftUI match detail / group preview before chatting
import SwiftUI

struct MatchDetailView: View {

    let match: Match
    @Environment(AppCoordinator.self) private var coordinator
    @State private var showUnmatch = false
    @State private var currentPhotoIdx = 0

    private var mvm: MatchViewModel { MatchViewModel(match) }
    private var group: Group? { match.matcher }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Member photo carousel
                if let members = group?.users, !members.isEmpty {
                    TabView(selection: $currentPhotoIdx) {
                        ForEach(members.indices, id: \.self) { idx in
                            let member = members[idx]
                            if let photo = member.photos.first(where: { $0.is_primary == true }) ?? member.photos.first,
                               let urlStr = photo.medium, let url = URL(string: urlStr) {
                                AsyncImage(url: url) { phase in
                                    switch phase {
                                    case .success(let img): img.resizable().scaledToFill()
                                    default: Color(.secondarySystemBackground)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 340)
                                .clipped()
                                .tag(idx)
                            }
                        }
                    }
                    .tabViewStyle(.page)
                    .frame(height: 340)
                    .indexViewStyle(.page(backgroundDisplayMode: .always))
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Group name + member count
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mvm.otherGroupName).font(.title2.bold())
                            if let gvm = group.map({ GroupViewModel($0) }) {
                                Text(gvm.memberCountText).font(.subheadline).foregroundStyle(.secondary)
                            }
                        }
                        Spacer()
                        // Distance badge
                        if let dist = match.distance, dist > 0 {
                            Label(String(format: "%.0f mi", dist), systemImage: "location.fill")
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }

                    // Members row
                    if let members = group?.users, !members.isEmpty {
                        Divider()
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(members, id: \.id) { member in
                                    VStack(spacing: 4) {
                                        memberAvatar(member)
                                        Text(member.first_name ?? "").font(.caption).lineLimit(1)
                                    }
                                    .frame(width: 60)
                                    .onTapGesture { coordinator.push(.userProfile(member, group)) }
                                }
                            }
                        }
                    }

                    // Action buttons
                    Divider()
                    HStack(spacing: 12) {
                        Button {
                            if let g = group {
                                coordinator.push(.chat(g, personalChat: false, matchId: match.chat_id))
                            }
                        } label: {
                            Label("Message", systemImage: "message.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button(role: .destructive) {
                            showUnmatch = true
                        } label: {
                            Label("Unmatch", systemImage: "xmark.circle")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle(mvm.otherGroupName)
        .navigationBarTitleDisplayMode(.inline)
        .alert("Unmatch?", isPresented: $showUnmatch) {
            Button("Unmatch", role: .destructive) {
                Task {
                    try? await MatchRepository.shared.unMatchTheGroup(groupId: String(group?.id ?? 0))
                    EntourageManager.shared.myMatchs.removeAll { $0.id == match.id }
                    lastMessageListner?.unsubscribe()
                    lastMessageListner = nil
                    if !EntourageManager.shared.myMatchs.isEmpty {
                        let listener = unReadMessageFirebaseService<LastMessage>.matchListener()
                        lastMessageListner = listener
                        listener?.lastMesssageUpdates { _, _ in }
                    }
                    coordinator.pop()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This cannot be undone.")
        }
    }

    @ViewBuilder
    private func memberAvatar(_ user: User) -> some View {
        if let photo = user.photos.first(where: { $0.is_primary == true }) ?? user.photos.first,
           let urlStr = photo.thumb, let url = URL(string: urlStr) {
            AsyncImage(url: url) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color(.tertiarySystemBackground) }
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
        } else {
            Circle().fill(Color(.secondarySystemBackground)).frame(width: 56, height: 56)
                .overlay(Image(systemName: "person.fill").foregroundStyle(.secondary))
        }
    }
}

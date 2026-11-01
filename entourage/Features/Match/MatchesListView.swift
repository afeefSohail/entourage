// MatchesListView.swift — SwiftUI matches & messages list
import SwiftUI

struct MatchesListView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = MatchesViewModel()
    @State private var matchToUnmatch: Match?
    @State private var showUnmatchAlert = false

    var body: some View {
        Group {
            if vm.isLoading && vm.matches.isEmpty {
                ProgressView()
            } else if vm.matches.isEmpty {
                ContentUnavailableView(
                    "No Matches Yet",
                    systemImage: "heart.slash",
                    description: Text("Keep swiping to find your perfect group match.")
                )
            } else {
                List {
                    ForEach(vm.matches, id: \.id) { match in
                        MatchRow(match: match) {
                            if let group = match.matcher {
                                coordinator.push(.chat(group, personalChat: false, matchId: match.id))
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                matchToUnmatch = match
                                showUnmatchAlert = true
                            } label: {
                                Label("Unmatch", systemImage: "xmark.circle")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Matches")
        .refreshable { await vm.refresh() }
        .task { await vm.refresh() }
        .alert("Unmatch?", isPresented: $showUnmatchAlert, presenting: matchToUnmatch) { match in
            Button("Unmatch", role: .destructive) {
                Task { await vm.unmatch(match) }
            }
            Button("Cancel", role: .cancel) {}
        } message: { match in
            Text("You will no longer be matched with \(match.matcher?.name ?? "this group").")
        }
    }
}

// MARK: - Row

private struct MatchRow: View {
    let match: Match
    let onTap: () -> Void

    private var mvm: MatchViewModel { MatchViewModel(match: match) }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Group avatar stack
                groupAvatarStack

                VStack(alignment: .leading, spacing: 3) {
                    HStack {
                        Text(mvm.otherGroupName)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        if mvm.isUnread {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 10, height: 10)
                        }
                    }
                    Text(mvm.lastMessage.isEmpty ? "Say hello!" : mvm.lastMessage)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
        }
        .foregroundStyle(.primary)
    }

    @ViewBuilder
    private var groupAvatarStack: some View {
        let members = mvm.otherGroup?.members ?? []
        ZStack {
            ForEach(members.prefix(3).indices, id: \.self) { idx in
                if let photo = members[idx].photos.first(where: { $0.is_primary == true }) ?? members[idx].photos.first,
                   let urlStr = photo.thumb, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { Color(.secondarySystemBackground) }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 1.5))
                    .offset(x: CGFloat(idx) * 14)
                }
            }
        }
        .frame(width: 44 + CGFloat(min(members.count, 3) - 1) * 14, height: 44)
        .padding(.trailing, CGFloat(min(members.count, 3) - 1) * 14)
    }
}

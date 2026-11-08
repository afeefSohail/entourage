// ProfileView.swift — SwiftUI profile screen (user's own group)
import SwiftUI

struct ProfileView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = ProfileViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Photo gallery
                if let primary = vm.user.photos.first(where: { $0.is_primary == true })
                                  ?? vm.user.photos.first,
                   let urlStr = primary.medium, !urlStr.isEmpty,
                   let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color(.secondarySystemBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 340)
                    .clipped()
                } else {
                    Color(.secondarySystemBackground).frame(height: 340)
                }

                VStack(alignment: .leading, spacing: 16) {
                    // Name + age
                    HStack {
                        Text(UserViewModel(vm.user).nameWithAge)
                            .font(.title2.bold())
                        Spacer()
                        Button {
                            coordinator.push(.editProfile)
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(.subheadline)
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(Color(.secondarySystemBackground))
                                .clipShape(Capsule())
                        }
                    }

                    // Group
                    if let group = vm.group {
                        Divider()
                        GroupInfoRow(group: group) {
                            coordinator.push(.groupManagement)
                        }
                    }

                    // Bio
                    if let bio = vm.user.bio, !bio.isEmpty {
                        Divider()
                        Text(bio)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }

                    // Photo grid
                    if vm.user.photos.count > 1 {
                        Divider()
                        PhotoGridView(photos: vm.user.photos) { _ in }
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .navigationTitle("My Profile")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable { await vm.refresh() }
        .task { await vm.refresh() }
        .overlay {
            if vm.isLoading && vm.user.photos.isEmpty {
                ProgressView()
            }
        }
    }
}

// MARK: - Reusable sub-views

struct GroupInfoRow: View {
    let group: Group
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let url = GroupViewModel(group).primaryMembers.first.flatMap({ UserViewModel($0).primaryPhotoURL }) {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { Color(.tertiarySystemBackground) }
                    }
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(group.name ?? "My Group").font(.headline)
                    Text(GroupViewModel(group).memberCountText).font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(.tertiary)
            }
        }
        .foregroundStyle(.primary)
    }
}

struct PhotoGridView: View {
    let photos: [Photo]
    let onTap: (Photo) -> Void
    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(photos.sorted { ($0.order ?? 0) < ($1.order ?? 0) }, id: \.id) { photo in
                if let urlStr = photo.medium, let url = URL(string: urlStr) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img): img.resizable().scaledToFill()
                        default: Color(.secondarySystemBackground)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fill)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onTapGesture { onTap(photo) }
                }
            }
        }
    }
}

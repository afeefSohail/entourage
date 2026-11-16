// SwipeView.swift — SwiftUI card swipe screen (replaces Koloda)
import SwiftUI

struct SwipeView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = SwipeViewModel()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if (vm.isLoading && vm.groups.isEmpty) || vm.groupState == .unknown {
                ProgressView("Finding groups…")
            } else if vm.groupState == .noGroup {
                noOwnGroupView
            } else if vm.groupState == .inactive {
                inactiveGroupView
            } else if vm.isEmpty {
                noGroupsView
            } else if vm.isExhausted {
                exhaustedView
            } else {
                cardStack
                overlayButtons
            }

            if vm.showMatchBanner, let match = vm.lastMatch {
                MatchBanner(match: match) {
                    vm.showMatchBanner = false
                    if let group = match.matcher {
                        coordinator.push(.chat(group, personalChat: false, matchId: match.chat_id))
                    }
                } onDismiss: {
                    vm.showMatchBanner = false
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(10)
            }
        }
        .navigationTitle("Discover")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { coordinator.push(.groupManagement) } label: {
                    Image(systemName: "person.3")
                }
                .accessibilityLabel("My Group")
            }
            ToolbarItem(placement: .primaryAction) {
                Button { coordinator.push(.filters) } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .task { await vm.loadIfNeeded() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Card stack

    @ViewBuilder
    private var cardStack: some View {
        ZStack {
            // Preview card below
            if vm.currentIndex + 1 < vm.groups.count {
                GroupCard(group: vm.groups[vm.currentIndex + 1])
                    .scaleEffect(0.94)
                    .offset(y: 14)
                    .allowsHitTesting(false)
            }

            // Top card — draggable
            if let group = vm.currentGroup {
                DraggableGroupCard(group: group) { direction in
                    Task {
                        if direction == .right { await vm.like() }
                        else { await vm.pass() }
                    }
                } onTap: { member in
                    coordinator.push(.userProfile(member, group))
                }
            }
        }
        // Even 16pt inset on all sides; the bottom also clears the floating like/pass buttons.
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 108)
    }

    // MARK: - Action buttons

    @ViewBuilder
    private var overlayButtons: some View {
        VStack {
            Spacer()
            HStack(spacing: 40) {
                actionButton(icon: "xmark", color: .red) {
                    Task { await vm.pass() }
                }
                actionButton(icon: "heart.fill", color: .green) {
                    Task { await vm.like() }
                }
            }
            .padding(.bottom, 24)
        }
    }

    private func actionButton(icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundStyle(color)
                .frame(width: 60, height: 60)
                .background(Circle().fill(Color(.systemBackground)).shadow(radius: 6))
        }
    }

    // MARK: - Empty states

    private var noOwnGroupView: some View {
        ContentUnavailableView {
            Label("Create Your Group", systemImage: "person.3.fill")
        } description: {
            Text("Swiping happens as a group. Add friends to your group to start discovering other groups.")
        } actions: {
            Button("Set Up Group") { coordinator.push(.groupManagement) }
                .buttonStyle(.borderedProminent)
        }
    }

    private var inactiveGroupView: some View {
        ContentUnavailableView {
            Label("Your Group Isn't Active Yet", systemImage: "person.2.badge.gearshape")
        } description: {
            Text("A group needs at least 2 members and a profile photo before it can swipe.")
        } actions: {
            Button("Manage Group") { coordinator.push(.groupManagement) }
                .buttonStyle(.borderedProminent)
        }
    }

    private var noGroupsView: some View {
        ContentUnavailableView {
            Label("No Groups Nearby", systemImage: "person.2.slash")
        } description: {
            Text("Try expanding your distance or adjusting your filters.")
        } actions: {
            Button("Refresh") { Task { await vm.loadInitial() } }
                .buttonStyle(.borderedProminent)
        }
    }

    private var exhaustedView: some View {
        ContentUnavailableView {
            Label("You've Seen Everyone", systemImage: "checkmark.circle")
        } description: {
            Text("Check back soon for new groups.")
        } actions: {
            Button("Refresh") { Task { await vm.loadInitial() } }
                .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Group card view

struct GroupCard: View {
    let group: Group
    var onMemberTap: ((User) -> Void)? = nil

    private let gap: CGFloat = 2
    private var members: [User] { GroupViewModel(group).primaryMembers }

    var body: some View {
        VStack(spacing: 0) {
            memberGrid
            infoBar
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.15), radius: 12, y: 6)
    }

    // 1 → full, 2 → top/bottom halves, 3 → top half split in two + full bottom, 4 → 2×2.
    @ViewBuilder
    private var memberGrid: some View {
        let m = members
        VStack(spacing: gap) {
            switch m.count {
            case 0:
                Color(.secondarySystemBackground)
            case 1:
                tile(m[0])
            case 2:
                tile(m[0])
                tile(m[1])
            case 3:
                HStack(spacing: gap) { tile(m[0]); tile(m[1]) }
                tile(m[2])
            default:
                HStack(spacing: gap) { tile(m[0]); tile(m[1]) }
                HStack(spacing: gap) { tile(m[2]); tile(m[3]) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // Color.clear sizes the tile; the photo overlays it so a fill-scaled image can never widen the card.
    private func tile(_ user: User) -> some View {
        let uvm = UserViewModel(user)
        return Color(.secondarySystemBackground)
            .overlay {
                AsyncImage(url: uvm.primaryPhotoURL) { phase in
                    if case .success(let img) = phase {
                        img.resizable().scaledToFill()
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .overlay(alignment: .bottomLeading) {
                Text(uvm.nameWithAge)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .shadow(color: .black.opacity(0.6), radius: 3)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                    )
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture { onMemberTap?(user) }
    }

    private var infoBar: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(group.cardsGroupName())
                    .font(.system(size: 20, weight: .heavy))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                if let place = placeText {
                    Text(place)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let distance = distanceText {
                Label(distance, systemImage: "mappin.and.ellipse")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize()
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var placeText: String? {
        let parts = [group.city, group.state].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: ", ")
    }

    private var distanceText: String? {
        guard let raw = group.distance, let miles = Double(raw) else { return nil }
        return miles < 1 ? "< 1 mi" : "\(Int(miles.rounded())) mi"
    }
}

// MARK: - Draggable card wrapper

enum SwipeDirection { case left, right }

struct DraggableGroupCard: View {
    let group: Group
    let onSwiped: (SwipeDirection) -> Void
    let onTap: (User) -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        GroupCard(group: group, onMemberTap: onTap)
            .overlay(swipeIndicator)
            .rotationEffect(.degrees(Double(dragOffset.width) / 20))
            .offset(dragOffset)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                        isDragging = true
                    }
                    .onEnded { value in
                        isDragging = false
                        if abs(value.translation.width) > swipeThreshold {
                            let direction: SwipeDirection = value.translation.width > 0 ? .right : .left
                            withAnimation(.spring(response: 0.3)) {
                                dragOffset = CGSize(
                                    width: direction == .right ? 600 : -600,
                                    height: value.translation.height
                                )
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                onSwiped(direction)
                                dragOffset = .zero
                            }
                        } else {
                            withAnimation(.spring()) { dragOffset = .zero }
                        }
                    }
            )
            .animation(.interactiveSpring(), value: dragOffset)
    }

    @ViewBuilder
    private var swipeIndicator: some View {
        if isDragging {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(dragOffset.width > 0 ? Color.green : Color.red, lineWidth: 4)
                .overlay(
                    SwiftUI.Group {
                        if dragOffset.width > 30 {
                            Text("LIKE").font(.title.bold()).foregroundStyle(.green).padding(20)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        } else if dragOffset.width < -30 {
                            Text("PASS").font(.title.bold()).foregroundStyle(.red).padding(20)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        }
                    }
                )
        }
    }
}

// MARK: - Match banner

struct MatchBanner: View {
    let match: Match
    let onChat: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "heart.fill").foregroundStyle(.pink).font(.title2)
                VStack(alignment: .leading, spacing: 2) {
                    Text("It's a Match!").font(.headline)
                    Text("You matched with \(match.matcher?.name ?? "a group")")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                Spacer()
                Button("Chat", action: onChat)
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .controlSize(.small)
                Button { onDismiss() } label: {
                    Image(systemName: "xmark").foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 8)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            Spacer()
        }
    }
}

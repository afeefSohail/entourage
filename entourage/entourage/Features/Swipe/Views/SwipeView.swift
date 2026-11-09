// SwipeView.swift — SwiftUI card swipe screen (replaces Koloda)
import SwiftUI

struct SwipeView: View {

    @Environment(AppCoordinator.self) private var coordinator
    @State private var vm = SwipeViewModel()

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            if vm.isLoading && vm.groups.isEmpty {
                ProgressView("Finding groups…")
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
            ToolbarItem(placement: .primaryAction) {
                Button { coordinator.push(.filters) } label: {
                    Image(systemName: "slider.horizontal.3")
                }
            }
        }
        .task { await vm.loadInitial() }
        .alert("Error", isPresented: .constant(vm.errorMessage != nil)) {
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
                } onTap: {
                    coordinator.push(.userProfile(group.users.first ?? User(), group))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 100)
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

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Primary photo
            if let member = group.users.first,
               let photo = member.photos.first(where: { $0.is_primary == true }) ?? member.photos.first,
               let urlStr = photo.original, let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let img): img.resizable().scaledToFill()
                    default: Color(.secondarySystemBackground)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
            } else {
                Color(.secondarySystemBackground)
            }

            // Gradient overlay
            LinearGradient(
                stops: [.init(color: .clear, location: 0.5), .init(color: .black.opacity(0.7), location: 1)],
                startPoint: .top, endPoint: .bottom
            )

            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(group.name ?? "Group")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                let gvm = GroupViewModel(group)
                Text(gvm.memberCountText)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.9))
            }
            .padding(20)
        }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .aspectRatio(2/3, contentMode: .fit)
    }
}

// MARK: - Draggable card wrapper

enum SwipeDirection { case left, right }

struct DraggableGroupCard: View {
    let group: Group
    let onSwiped: (SwipeDirection) -> Void
    let onTap: () -> Void

    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    private let swipeThreshold: CGFloat = 100

    var body: some View {
        GroupCard(group: group)
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
            .onTapGesture(perform: onTap)
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

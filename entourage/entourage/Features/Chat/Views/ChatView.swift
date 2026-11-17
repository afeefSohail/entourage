// ChatView.swift — SwiftUI chat screen (personal group chat + match cross-group chat)
import SwiftUI

private enum ChatStyle {
    static let outgoing = Color("themeColor")
    static let incoming = Color(.systemGray5)                              // #E9E9EB in light mode
    static let avatarSize: CGFloat = 34
    static let avatarGap: CGFloat = 6
    static let sidePadding: CGFloat = 8
}

struct ChatView: View {

    @State private var vm: ChatViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(group: Group, personalChat: Bool, matchId: Int) {
        _vm = State(initialValue: ChatViewModel(group: group, personalChat: personalChat, matchId: matchId))
    }

    var body: some View {
        VStack(spacing: 0) {
            if !vm.notificationsEnabled {
                notificationBanner
            }

            ZStack {
                messagesList
                if !vm.isLoading && vm.messages.isEmpty {
                    emptyState
                }
            }

            inputBar
        }
        .background(Color(.systemBackground))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { header }
        }
        .overlay {
            if vm.isLoading && vm.messages.isEmpty {
                ProgressView()
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
        .task { await vm.refreshNotificationStatus() }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Task { await vm.refreshNotificationStatus() }
        }
        .alert("Chat Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            AvatarStack(users: vm.headerMembers)
            VStack(alignment: .leading, spacing: 1) {
                Text(vm.headerTitle)
                    .font(.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                Text(vm.headerSubtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Notification banner

    private var notificationBanner: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("See when they respond")
                    .font(.system(size: 16, weight: .semibold))
                Text("Enable push notifications")
                    .font(.system(size: 13))
                    .opacity(0.9)
            }
            .foregroundStyle(.white)
            Spacer()
            Button("Enable") {
                Task { await vm.enableNotifications() }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color("themeColor"))
            .padding(.horizontal, 16)
            .padding(.vertical, 7)
            .background(Capsule().fill(.white))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            LinearGradient(colors: [Color("themeColor"), Color("themeColor").opacity(0.75)],
                           startPoint: .leading, endPoint: .trailing)
        )
    }

    // MARK: - Messages

    private var messagesList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(Array(vm.messages.enumerated()), id: \.element.id) { index, msg in
                        messageRow(index: index, message: msg)
                            .id(msg.id)
                    }
                }
                .padding(.vertical, 10)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: vm.messages.count) { _, _ in
                if let last = vm.messages.last {
                    withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                }
            }
        }
    }

    @ViewBuilder
    private func messageRow(index: Int, message: ChatMessage) -> some View {
        let messages = vm.messages
        let prev = index > 0 ? messages[index - 1] : nil
        let next = index + 1 < messages.count ? messages[index + 1] : nil
        let showDate = prev.map { !Self.sameDay($0, message) } ?? true
        let firstInRun = showDate || prev?.sender.id != message.sender.id
        let lastInRun = next.map { $0.sender.id != message.sender.id || !Self.sameDay($0, message) } ?? true
        let mine = vm.isFromMySide(message)

        VStack(spacing: 0) {
            if showDate {
                Text(Self.dateHeader(for: message))
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                    .padding(.top, index == 0 ? 6 : 20)
                    .padding(.bottom, 12)
            }

            ChatMessageRow(
                message: message,
                isMine: mine,
                firstInRun: firstInRun,
                lastInRun: lastInRun,
                footer: lastInRun ? footerText(for: message, mine: mine) : nil,
                onAvatarTap: { openProfile(for: message) }
            )
            .padding(.bottom, lastInRun ? 12 : 2)
        }
    }

    private func footerText(for message: ChatMessage, mine: Bool) -> String {
        if message.sender.id == "\(EntourageManager.shared.user.id)",
           vm.messages.last(where: { $0.sender.id == message.sender.id })?.id == message.id {
            return "Delivered"
        }
        return "\(vm.senderName(message))  \(Self.timeAgo(message))"
    }

    private func openProfile(for message: ChatMessage) {
        guard message.sender.id != "\(EntourageManager.shared.user.id)",
              let user = vm.member(for: message) else { return }
        coordinator.push(.userProfile(user, nil))
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .font(.system(size: 44))
                .foregroundStyle(ChatStyle.outgoing.opacity(0.8))
            Text(vm.emptyTitle)
                .font(.system(size: 20, weight: .heavy))
                .italic()
            Text(vm.emptyMessage)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .padding(.top, 60)
        .allowsHitTesting(false)
    }

    // MARK: - Input bar

    private var canSend: Bool {
        !vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 4) {
            TextField("Type a message", text: $vm.inputText, axis: .vertical)
                .font(.system(size: 16))
                .lineLimit(1...5)
                .submitLabel(.send)
                .onSubmit { if canSend { vm.send() } }
                .padding(.leading, 16)
                .padding(.vertical, 10)

            Button("Send") { vm.send() }
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(canSend ? ChatStyle.outgoing : Color(.systemGray3))
                .disabled(!canSend)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Color(.systemBackground)
                .shadow(color: .black.opacity(0.06), radius: 6, y: -2)
        )
    }

    // MARK: - Date helpers

    private static func date(_ m: ChatMessage) -> Date { Date(timeIntervalSince1970: m.createdAt) }

    private static func sameDay(_ a: ChatMessage, _ b: ChatMessage) -> Bool {
        Calendar.current.isDate(date(a), inSameDayAs: date(b))
    }

    private static let dayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM dd"
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()

    private static func dateHeader(for m: ChatMessage) -> String {
        let d = date(m)
        if Calendar.current.isDateInToday(d) { return "Today at \(timeFormatter.string(from: d))" }
        if Calendar.current.isDateInYesterday(d) { return "Yesterday at \(timeFormatter.string(from: d))" }
        return dayFormatter.string(from: d)
    }

    private static func timeAgo(_ m: ChatMessage) -> String {
        let seconds = Date().timeIntervalSince(date(m))
        switch seconds {
        case ..<60: return "now"
        case ..<3600: return "\(Int(seconds / 60))m ago"
        case ..<86400: return "\(Int(seconds / 3600))h ago"
        default: return timeFormatter.string(from: date(m))
        }
    }
}

// MARK: - Message row

private struct ChatMessageRow: View {

    let message: ChatMessage
    let isMine: Bool
    let firstInRun: Bool
    let lastInRun: Bool
    let footer: String?
    let onAvatarTap: () -> Void

    var body: some View {
        VStack(alignment: isMine ? .trailing : .leading, spacing: 3) {
            HStack(alignment: .bottom, spacing: ChatStyle.avatarGap) {
                if isMine { Spacer(minLength: 50) } else { avatarSlot }
                bubble
                if isMine { avatarSlot } else { Spacer(minLength: 50) }
            }

            if let footer {
                Text(footer)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .padding(isMine ? .trailing : .leading, ChatStyle.avatarSize + ChatStyle.avatarGap + 2)
            }
        }
        .padding(.horizontal, ChatStyle.sidePadding)
    }

    // The avatar sits beside the last bubble of a run; earlier bubbles keep the space so they stay aligned.
    @ViewBuilder
    private var avatarSlot: some View {
        if lastInRun {
            ChatAvatar(name: message.sender.displayName, photoURL: URL(string: message.sender.photoUrl), size: ChatStyle.avatarSize)
                .onTapGesture(perform: onAvatarTap)
        } else {
            Color.clear.frame(width: ChatStyle.avatarSize, height: 1)
        }
    }

    // Grouped bubbles keep a 16pt radius except a 4pt "tail" side that points at the sender.
    private var shape: UnevenRoundedRectangle {
        let big: CGFloat = 16, small: CGFloat = 4
        let topSide = firstInRun ? big : small
        return isMine
            ? UnevenRoundedRectangle(topLeadingRadius: big, bottomLeadingRadius: big,
                                     bottomTrailingRadius: small, topTrailingRadius: topSide, style: .continuous)
            : UnevenRoundedRectangle(topLeadingRadius: topSide, bottomLeadingRadius: small,
                                     bottomTrailingRadius: big, topTrailingRadius: big, style: .continuous)
    }

    @ViewBuilder
    private var bubble: some View {
        switch message.messageData.type {
        case .Photo:
            if let url = URL(string: message.messageData.mediaUrl), !message.messageData.mediaUrl.isEmpty {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color(.secondarySystemBackground) }
                }
                .frame(width: 200, height: 200)
                .clipShape(shape)
            }
        default:
            Text(message.messageData.text.isEmpty ? "[Media]" : message.messageData.text)
                .font(.system(size: 16))
                .foregroundStyle(isMine ? Color.white : Color.primary)
                .padding(.horizontal, 13)
                .padding(.vertical, 9)
                .background(shape.fill(isMine ? ChatStyle.outgoing : ChatStyle.incoming))
        }
    }
}

// MARK: - Avatars

private struct ChatAvatar: View {
    let name: String
    let photoURL: URL?
    let size: CGFloat

    var body: some View {
        Circle()
            .fill(Color(.systemGray4))
            .overlay {
                if let photoURL {
                    AsyncImage(url: photoURL) { phase in
                        if case .success(let img) = phase { img.resizable().scaledToFill() }
                        else { initials }
                    }
                } else {
                    initials
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    private var initials: some View {
        Text(String(name.prefix(1)).uppercased())
            .font(.system(size: size * 0.42, weight: .semibold))
            .foregroundStyle(.white)
    }
}

private struct AvatarStack: View {
    let users: [User]
    private let size: CGFloat = 32

    var body: some View {
        HStack(spacing: -size * 0.3) {
            ForEach(Array(users.prefix(3).enumerated()), id: \.element.id) { _, user in
                let uvm = UserViewModel(user)
                ChatAvatar(name: uvm.displayName, photoURL: uvm.primaryPhotoURL, size: size)
                    .overlay(Circle().stroke(Color(.systemBackground), lineWidth: 2))
            }
        }
    }
}

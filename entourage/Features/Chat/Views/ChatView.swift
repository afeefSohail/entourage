// ChatView.swift — SwiftUI chat screen (personal group chat + match cross-group chat)
import SwiftUI

struct ChatView: View {

    @State private var vm: ChatViewModel
    @Environment(AppCoordinator.self) private var coordinator

    init(group: Group, personalChat: Bool, matchId: Int) {
        _vm = State(initialValue: ChatViewModel(group: group, personalChat: personalChat, matchId: matchId))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(vm.messages, id: \.id) { msg in
                            ChatBubble(
                                message: msg,
                                isFromMe: vm.isFromCurrentUser(msg),
                                senderName: vm.senderName(msg),
                                senderPhotoURL: vm.senderPhotoURL(msg)
                            )
                            .id(msg.id)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .onChange(of: vm.messages.count) { _, _ in
                    if let last = vm.messages.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider()

            // Input bar
            HStack(spacing: 8) {
                TextField("Type a message", text: $vm.inputText, axis: .vertical)
                    .lineLimit(1...5)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                Button {
                    vm.send()
                } label: {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty ? .secondary : .blue)
                }
                .disabled(vm.inputText.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .navigationTitle(vm.chatTitle)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if vm.isLoading && vm.messages.isEmpty {
                ProgressView()
            }
        }
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }
}

// MARK: - Bubble cell

private struct ChatBubble: View {

    let message: ChatMessage
    let isFromMe: Bool
    let senderName: String
    let senderPhotoURL: URL?

    var body: some View {
        HStack(alignment: .bottom, spacing: 6) {
            if isFromMe { Spacer(minLength: 60) }

            if !isFromMe {
                avatarView
            }

            VStack(alignment: isFromMe ? .trailing : .leading, spacing: 2) {
                if !isFromMe {
                    Text(senderName)
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .padding(.leading, 4)
                }
                bubbleContent
                Text(formattedTime)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 4)
            }

            if !isFromMe { Spacer(minLength: 60) }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }

    @ViewBuilder
    private var avatarView: some View {
        if let url = senderPhotoURL {
            AsyncImage(url: url) { phase in
                if case .success(let img) = phase { img.resizable().scaledToFill() }
                else { Color(.tertiarySystemBackground) }
            }
            .frame(width: 30, height: 30)
            .clipShape(Circle())
        } else {
            Circle()
                .fill(Color(.secondarySystemBackground))
                .frame(width: 30, height: 30)
                .overlay(Image(systemName: "person.fill").font(.caption).foregroundStyle(.secondary))
        }
    }

    @ViewBuilder
    private var bubbleContent: some View {
        switch message.messageData.type {
        case .Text, .URL:
            Text(message.messageData.text)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isFromMe ? Color.blue : Color(.secondarySystemBackground))
                .foregroundStyle(isFromMe ? .white : .primary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        case .Photo:
            if let urlStr = message.messageData.mediaUrl.isEmpty ? nil : message.messageData.mediaUrl,
               let url = URL(string: urlStr) {
                AsyncImage(url: url) { phase in
                    if case .success(let img) = phase { img.resizable().scaledToFill() }
                    else { Color(.secondarySystemBackground) }
                }
                .frame(width: 200, height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        default:
            Text(message.messageData.text.isEmpty ? "[Media]" : message.messageData.text)
                .foregroundStyle(.secondary)
                .italic()
        }
    }

    private var formattedTime: String {
        let date = Date(timeIntervalSince1970: message.createdAt)
        let fmt = DateFormatter()
        fmt.dateStyle = .none
        fmt.timeStyle = .short
        return fmt.string(from: date)
    }
}

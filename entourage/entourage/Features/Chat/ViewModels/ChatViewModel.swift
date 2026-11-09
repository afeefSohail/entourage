// ChatViewModel.swift — screen VM for chat, preserving personalChat: Bool distinction
import Foundation
import Observation
import FirebaseMessaging

@Observable
@MainActor
final class ChatViewModel {

    // MARK: - Public state
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading = false
    var errorMessage: String?

    // MARK: - Configuration (set before onAppear)
    let group: Group
    let personalChat: Bool
    let matchId: Int

    // MARK: - Private
    private var service: MessageFirebaseService<ChatMessage>?
    private var activeMemberService: ActiveMemberFireBaseService<ActiveMember>?
    private var currentUser: ChatUser
    private var myUserId: String { "\(EntourageManager.shared.user.id)" }



    var chatRoomId: String {
        personalChat ? "\(group.id)" : "Match_\(matchId)"
    }

    var chatTitle: String { group.name ?? "Chat" }

    init(group: Group, personalChat: Bool, matchId: Int) {
        self.group = group
        self.personalChat = personalChat
        self.matchId = matchId
        self.currentUser = EntourageManager.shared.user.getChatUser(sideId: EntourageManager.shared.myGroup?.id ?? 0)
    }

    // MARK: - Lifecycle

    func start() {
        let svc = ChatRepository.shared.createListener(id: chatRoomId)
        self.service = svc
        isLoading = true
        svc.fetch(pageSize: 100, completion: { [weak self] loaded in
            guard let self else { return }
            Task { @MainActor in
                self.messages = loaded.sorted { $0.createdAt < $1.createdAt }
                self.isLoading = false
                self.subscribeForNew()
            }
        }, callCompletionIfEmptyResult: true)
        writeActiveMember()
    }

    func stop() {
        service?.unsubscribe()
        service = nil
        deleteActiveMember()
    }

    private func writeActiveMember() {
        let svc = ActiveMemberFireBaseService<ActiveMember>.creatActiveListner(id: chatRoomId)
        self.activeMemberService = svc
        let fcmToken = Messaging.messaging().fcmToken
        let member = ActiveMember(senderId: myUserId, status: true, fcmToken: fcmToken)
        svc.addAcvtiveDoc(docId: myUserId, element: member) { _, _ in }
    }

    private func deleteActiveMember() {
        activeMemberService?.delete(docId: myUserId) { _ in }
        activeMemberService = nil
    }

    private func subscribeForNew() {
        service?.subscribeForUpdates(limit: 200) { [weak self] newMessages in
            guard let self else { return }
            Task { @MainActor in
                for msg in newMessages where !self.messages.contains(where: { $0.id == msg.id }) {
                    self.messages.append(msg)
                }
                self.messages.sort { $0.createdAt < $1.createdAt }
            }
        }
    }

    // MARK: - Send

    func send() {
        let text = inputText.trimmingCharacters(in: .whitespaces)
        guard !text.isEmpty else { return }
        inputText = ""
        let msg = ChatMessage(text: text, sender: currentUser, emoticon: .Neutral)
        service?.add(element: msg) { _, _ in }
    }

    // MARK: - Helpers

    func isFromCurrentUser(_ message: ChatMessage) -> Bool {
        message.sender.id == currentUser.id
    }

    func senderName(_ message: ChatMessage) -> String { message.sender.displayName }

    func senderPhotoURL(_ message: ChatMessage) -> URL? {
        URL(string: message.sender.photoUrl)
    }
}

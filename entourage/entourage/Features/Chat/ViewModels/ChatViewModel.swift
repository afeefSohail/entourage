// ChatViewModel.swift — screen VM for chat, preserving personalChat: Bool distinction
import Foundation
import Observation
import FirebaseMessaging
import UIKit
import UserNotifications

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

    var notificationsEnabled = true

    private var myGroup: Group? { EntourageManager.shared.myGroup }
    private var myUserIntId: Int { EntourageManager.shared.user.id }

    // MARK: - Header / empty state

    /// Faces shown in the top bar: the other group in a match chat, everyone but me in my group chat.
    var headerMembers: [User] {
        let source = personalChat ? (myGroup?.users ?? group.users) : group.users
        return source.filter { $0.id != myUserIntId }
    }

    var headerTitle: String {
        personalChat ? (myGroup ?? group).myGroupName() : group.matcherGroupName()
    }

    var headerSubtitle: String {
        "Group of \(personalChat ? (myGroup ?? group).users.count : group.users.count)"
    }

    var emptyTitle: String { personalChat ? "Group Chat" : "Send a Message" }

    var emptyMessage: String {
        personalChat
            ? "Message your group here, don't worry nobody outside your group can see."
            : "You've matched with \(group.matcherGroupName()), send them a message."
    }

    // MARK: - Message helpers

    /// Right-hand side: in a match chat everything my group sends; in my group chat only my own messages.
    func isFromMySide(_ message: ChatMessage) -> Bool {
        if personalChat { return message.sender.id == myUserId }
        if let mine = myGroup {
            if message.sender.groupId != 0 { return message.sender.groupId == mine.id }
            return mine.users.contains { "\($0.id)" == message.sender.id }
        }
        return message.sender.id == myUserId
    }

    func member(for message: ChatMessage) -> User? {
        let everyone = (myGroup?.users ?? []) + group.users
        return everyone.first { "\($0.id)" == message.sender.id }
    }

    // MARK: - Notifications banner

    func refreshNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional
    }

    func enableNotifications() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshNotificationStatus()
        } else if let url = URL(string: UIApplication.openSettingsURLString) {
            await UIApplication.shared.open(url)
        }
    }

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
        }, callCompletionIfEmptyResult: true, failure: { [weak self] error in
            Task { @MainActor in
                self?.isLoading = false
                self?.errorMessage = Self.describe(error)
            }
        })
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
        service?.add(element: msg) { [weak self] _, error in
            guard let error else { return }
            Task { @MainActor in
                guard let self else { return }
                if self.inputText.isEmpty { self.inputText = text }
                self.errorMessage = Self.describe(error)
            }
        }
    }

    // Firestore permission errors mean the project's security rules rejected this user, not a network problem.
    private static func describe(_ error: Error) -> String {
        let ns = error as NSError
        if ns.domain == "FIRFirestoreErrorDomain" && ns.code == 7 {
            return "Chat is unavailable: the server refused access to this conversation."
        }
        return "Couldn't reach chat. \(error.localizedDescription)"
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

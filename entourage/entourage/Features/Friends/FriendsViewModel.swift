// FriendsViewModel.swift
import Foundation
import Contacts
import SwiftUI

enum FriendsTab: String, CaseIterable {
    case all      = "All"
    case requests = "Requests"
    case contacts = "Contacts"
}

@Observable
@MainActor
final class FriendsViewModel {

    // MARK: - Tab state
    var selectedTab: FriendsTab = .all
    var searchText: String = ""

    // MARK: - All tab
    var friends: [User] = []
    var searchResults: [User] = []

    // MARK: - Requests tab
    var requests: [User] = []

    // MARK: - Contacts tab
    var contactAppUsers: [User] = []
    var contactNonAppUsers: [(phone: String, name: String)] = []
    var hasContactsPermission = true

    // MARK: - Loading / error
    var isLoading = false
    var errorMessage: String?

    // MARK: - Optimistic UI sets
    var sentRequestIds:     Set<Int>    = []
    var acceptedRequestIds: Set<Int>    = []
    var rejectedRequestIds: Set<Int>    = []
    var invitedNumbers:     Set<String> = []
    var pendingInviteURL:   URL?

    private let repo = UserRepository.shared

    // MARK: - Public API

    func onTabChanged() async {
        searchText = ""
        switch selectedTab {
        case .all:      await loadFriends()
        case .requests: await loadRequests()
        case .contacts: await loadContacts()
        }
    }

    func onAppear() async {
        await loadFriends()
    }

    func onSearchTextChanged() async {
        guard selectedTab == .all else { return }
        if searchText.isEmpty {
            searchResults = []
        } else {
            await performSearch()
        }
    }

    func sendRequest(to user: User) async {
        sentRequestIds.insert(user.id)
        do {
            try await repo.sendRequest(friendId: user.id)
        } catch {
            sentRequestIds.remove(user.id)
            errorMessage = error.localizedDescription
        }
    }

    func acceptRequest(from user: User) async {
        acceptedRequestIds.insert(user.id)
        do {
            try await repo.acceptRequest(friendId: user.id)
            requests.removeAll { $0.id == user.id }
        } catch {
            acceptedRequestIds.remove(user.id)
            errorMessage = error.localizedDescription
        }
    }

    func rejectRequest(from user: User) async {
        rejectedRequestIds.insert(user.id)
        do {
            try await repo.rejectRequest(friendId: user.id)
            requests.removeAll { $0.id == user.id }
        } catch {
            rejectedRequestIds.remove(user.id)
            errorMessage = error.localizedDescription
        }
    }

    func unfriend(_ user: User) async {
        friends.removeAll { $0.id == user.id }
        do {
            try await repo.unFriend(friendId: user.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func sendInvite(phone: String) async {
        invitedNumbers.insert(phone)
        do {
            if let urlStr = try await repo.sendInviteMessage(phoneNumber: phone),
               let url = URL(string: urlStr) {
                pendingInviteURL = url
            }
        } catch {
            invitedNumbers.remove(phone)
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private loaders

    private func loadFriends() async {
        isLoading = true
        defer { isLoading = false }
        do {
            friends = try await repo.getFriendsList()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadRequests() async {
        isLoading = true
        defer { isLoading = false }
        do {
            requests = try await repo.getReceivedRequests()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func loadContacts() async {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        guard status == .authorized else {
            hasContactsPermission = (status == .notDetermined)
            if status == .notDetermined {
                let store = CNContactStore()
                let granted = (try? await store.requestAccess(for: .contacts)) ?? false
                hasContactsPermission = granted
                if granted { await loadContacts() }
            }
            return
        }
        hasContactsPermission = true
        isLoading = true
        defer { isLoading = false }

        let phoneContacts = await Task.detached(priority: .userInitiated) {
            PhoneContacts.getAllContacts()
        }.value

        var nameMap: [String: String] = [:]
        let numbersString = phoneContacts.map { c -> String in
            nameMap[c.phoneNumber] = c.name ?? c.shortName ?? c.phoneNumber
            return c.phoneNumber
        }.joined(separator: ",")

        guard !numbersString.isEmpty else { return }

        do {
            let result = try await repo.getFriendsAndInvited(contacts: numbersString)
            contactAppUsers = result.friendships
            contactNonAppUsers = result.nonExisting.map { phone in
                (phone: phone, name: nameMap[phone] ?? phone)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func performSearch() async {
        let query = searchText
        do {
            searchResults = try await repo.searchBy(userName: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

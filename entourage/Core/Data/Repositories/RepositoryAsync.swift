// RepositoryAsync.swift — async/await bridges for all repository protocols
import Foundation
import UIKit

// MARK: - Error type

struct RepositoryError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

// MARK: - GroupRepository async

extension GroupRepository {

    func addMember(groupId: Int, friendsId: Int) async throws -> Group? {
        try await withCheckedThrowingContinuation { cont in
            addMember(groupId: groupId, friendsId: friendsId) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Group)
            }
        }
    }

    func createGroup(friendsIds: String) async throws -> Group? {
        try await withCheckedThrowingContinuation { cont in
            createGroup(friendsIds: friendsIds) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Group)
            }
        }
    }

    func myGroup() async throws -> Group? {
        try await withCheckedThrowingContinuation { cont in
            myGroup { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Group)
            }
        }
    }

    func leaveGroup() async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            leaveGroup { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func getGroupBy(groupId: Int) async throws -> Group? {
        try await withCheckedThrowingContinuation { cont in
            getGroupBy(groupId: groupId) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Group)
            }
        }
    }
}

// MARK: - MatchRepository async

extension MatchRepository {

    func findGroupsToMatch(page: Int) async throws -> OtherGroups? {
        try await withCheckedThrowingContinuation { cont in
            findGroupsToMatch(page: page) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? OtherGroups)
            }
        }
    }

    func likeTheGroup(groupId: String) async throws -> Match? {
        try await withCheckedThrowingContinuation { cont in
            likeTheGroup(groupId: groupId) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Match)
            }
        }
    }

    func unLikeTheGroup(groupId: String) async throws -> Match? {
        try await withCheckedThrowingContinuation { cont in
            unLikeTheGroup(groupId: groupId) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Match)
            }
        }
    }

    func matchList() async throws -> [Match] {
        try await withCheckedThrowingContinuation { cont in
            matchList { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [Match]) ?? [])
            }
        }
    }

    func unMatchTheGroup(groupId: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            unMatchTheGroup(groupId: groupId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }
}

// MARK: - UserRepository async

extension UserRepository {

    func getUser() async throws -> User? {
        try await withCheckedThrowingContinuation { cont in
            getUser { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? User)
            }
        }
    }

    func editUserProfile(checkAge: Bool) async throws -> User? {
        try await withCheckedThrowingContinuation { cont in
            editUserProfile(checkAge: checkAge) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? User)
            }
        }
    }

    func getUserSettings() async throws -> Setting? {
        try await withCheckedThrowingContinuation { cont in
            getUserSettings { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Setting)
            }
        }
    }

    func updateSettings() async throws -> Setting? {
        try await withCheckedThrowingContinuation { cont in
            updateSettings { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Setting)
            }
        }
    }

    func uploadPhoto(image: Data, isPrimary: Bool, order: Int) async throws -> User? {
        try await withCheckedThrowingContinuation { cont in
            uploadPhoto(image: image, isPrimary: isPrimary, order: order) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? User)
            }
        }
    }

    func deletePhoto(photoId: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            deletePhoto(photoId: photoId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func setOrderPhoto(photoId: Int, order: Int, isPrimary: Bool) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            setOrderPhoto(photoId: photoId, order: order, isPrimary: isPrimary) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func getFriendsList() async throws -> [User] {
        try await withCheckedThrowingContinuation { cont in
            getFriendsList { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [User]) ?? [])
            }
        }
    }

    func blockFriend(friendId: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            blockFriend(friendId: friendId, reason: nil, abusiveMsg: nil) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func unblockedUsers(blockUserIds: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            unblockedUsers(blockUserIds: blockUserIds) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func getBlockedFriends() async throws -> [User] {
        try await withCheckedThrowingContinuation { cont in
            getBlockedFriends { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [User]) ?? [])
            }
        }
    }

    func checkUserFriendStatus(friendId: Int) async throws -> String? {
        try await withCheckedThrowingContinuation { cont in
            checkUserFriendStatus(friendId: friendId) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? String)
            }
        }
    }

    func sendRequest(friendId: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            sendRequest(friendId: friendId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }
    func unFriend(friendId: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            unFriend(friendId: friendId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func reportUser(userId: Int, reason: String) async throws {
        let u = User(); u.id = userId
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            reportUser(userVM: UserViewModel(u), reason: reason, image: UIImage()) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func getReceivedRequests() async throws -> [User] {
        try await withCheckedThrowingContinuation { cont in
            getReceivedRequests { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [User]) ?? [])
            }
        }
    }

    func acceptRequest(friendId: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            acceptRequest(friendId: friendId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func rejectRequest(friendId: Int) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            rejectRequest(friendId: friendId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func searchBy(userName: String) async throws -> [User] {
        try await withCheckedThrowingContinuation { cont in
            searchBy(userName: userName) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [User]) ?? [])
            }
        }
    }

    func getAppContacts() async throws -> [User] {
        try await withCheckedThrowingContinuation { cont in
            getAppContacts { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [User]) ?? [])
            }
        }
    }

    func getFriendsAndInvited(contacts: String) async throws -> FriendsWithInvitedUser {
        try await withCheckedThrowingContinuation { cont in
            getFriendsAndInvited(contacts: contacts) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? FriendsWithInvitedUser) ?? FriendsWithInvitedUser())
            }
        }
    }

    func userSignUp(phoneNum: String) async throws -> User? {
        try await withCheckedThrowingContinuation { cont in
            userSignUp(phoneNum: phoneNum) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? User)
            }
        }
    }

    func getUserBy(phoneNum: String) async throws -> User? {
        try await withCheckedThrowingContinuation { cont in
            getUserBy(phoneNum: phoneNum) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? User)
            }
        }
    }

    func checkUserNameAvailability(userName: String) async throws {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<Void, Error>) in
            checkUserNameAvailability(userName: userName) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume()
            }
        }
    }

    func directFriendShip(phoneNumber: String) async throws -> DirectFriendshipResult? {
        try await withCheckedThrowingContinuation { cont in
            directFriendShip(phoneNumber: phoneNumber) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? DirectFriendshipResult)
            }
        }
    }

    func getFriendsListBy(contacts: String, directFriendship: Bool) async throws -> [User] {
        try await withCheckedThrowingContinuation { cont in
            getFriendsListBy(contacts: contacts, directFriendship: directFriendship) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [User]) ?? [])
            }
        }
    }

}
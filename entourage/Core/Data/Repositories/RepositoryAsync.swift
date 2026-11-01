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

    func createGroup(groupStatusId: Int, friendsIds: String) async throws -> Group? {
        try await withCheckedThrowingContinuation { cont in
            createGroup(groupStatusId: groupStatusId, friendsIds: friendsIds) { result, error in
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
        try await withCheckedThrowingContinuation { cont in
            leaveGroup { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
            }
        }
    }

    func acceptGroupInvite(groupId: Int) async throws -> Group? {
        try await withCheckedThrowingContinuation { cont in
            acceptGroupInvite(groupId: groupId) { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: result as? Group)
            }
        }
    }

    func rejectGroupInvite(groupId: Int) async throws {
        try await withCheckedThrowingContinuation { cont in
            rejectGroupInvite(groupId: groupId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
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
        try await withCheckedThrowingContinuation { cont in
            unMatchTheGroup(groupId: groupId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
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
        try await withCheckedThrowingContinuation { cont in
            deletePhoto(photoId: photoId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
            }
        }
    }

    func setOrderPhoto(photoId: Int, order: Int, isPrimary: Bool) async throws {
        try await withCheckedThrowingContinuation { cont in
            setOrderPhoto(photoId: photoId, order: order, isPrimary: isPrimary) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
            }
        }
    }

    func getFriendsList() async throws -> [Friend] {
        try await withCheckedThrowingContinuation { cont in
            getFriendsList { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [Friend]) ?? [])
            }
        }
    }

    func blockFriend(friendId: Int) async throws {
        try await withCheckedThrowingContinuation { cont in
            blockFriend(friendId: friendId, reason: nil, abusiveMsg: nil) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
            }
        }
    }

    func unblockedUsers(blockUserIds: String) async throws {
        try await withCheckedThrowingContinuation { cont in
            unblockedUsers(blockUserIds: blockUserIds) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
            }
        }
    }

    func getBlockedFriends() async throws -> [Friend] {
        try await withCheckedThrowingContinuation { cont in
            getBlockedFriends { result, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: (result as? [Friend]) ?? [])
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
        try await withCheckedThrowingContinuation { cont in
            sendRequest(friendId: friendId) { _, error in
                if let error { cont.resume(throwing: RepositoryError(message: error)); return }
                cont.resume(returning: ())
            }
        }
    }
}

// WebservicesManager.swift — compatibility shim that delegates to typed repositories.
// All business logic now lives in Core/Data/Repositories/.
import Foundation
import UIKit

typealias WebServicesManagerCallback = RepoCallback

class WebServicesManager: NSObject {

    static let shared = WebServicesManager()

    private let users   = UserRepository.shared
    private let groups  = GroupRepository.shared
    private let matches = MatchRepository.shared

    fileprivate override init() { super.init() }

    // MARK: - Auth / Profile
    func checkUdpatetion(callback: @escaping WebServicesManagerCallback) { users.checkUpdatetion(callback: callback) }
    func UserSignUpBy(phoneNum: String, callback: @escaping WebServicesManagerCallback) { users.userSignUp(phoneNum: phoneNum, callback: callback) }
    func getUser(callback: @escaping WebServicesManagerCallback) { users.getUser(callback: callback) }
    func getUserBy(phoneNum: String, callback: @escaping WebServicesManagerCallback) { users.getUserBy(phoneNum: phoneNum, callback: callback) }
    func editUserProfile(checkAge: Bool, callback: @escaping WebServicesManagerCallback) { users.editUserProfile(checkAge: checkAge, callback: callback) }
    func checkUserNameAvailablityBy(userName: String, callback: @escaping WebServicesManagerCallback) { users.checkUserNameAvailability(userName: userName, callback: callback) }
    func deleteUserAccount(reason: String, callback: @escaping WebServicesManagerCallback) { users.deleteUserAccount(reason: reason, callback: callback) }
    func updateLocationBy(callback: @escaping WebServicesManagerCallback) { users.updateLocation(callback: callback) }
    func searchBy(userName: String, callback: @escaping WebServicesManagerCallback) { users.searchBy(userName: userName, callback: callback) }
    func reportUser(user: User, reason: String, image: UIImage, callback: @escaping WebServicesManagerCallback) { users.reportUser(user: user, reason: reason, image: image, callback: callback) }
    func sendInviteMessage(phoneNumber: String, callback: @escaping WebServicesManagerCallback) { users.sendInviteMessage(phoneNumber: phoneNumber, callback: callback) }

    // MARK: - Photos
    func uploadPhoto(image: Data, isPrimary: Bool, order: Int, callback: @escaping WebServicesManagerCallback) { users.uploadPhoto(image: image, isPrimary: isPrimary, order: order, callback: callback) }
    func deletePhotot(photoId: Int, callback: @escaping WebServicesManagerCallback) { users.deletePhoto(photoId: photoId, callback: callback) }
    func setOrderPhotot(photoId: Int, order: Int, isPrimary: Bool, callback: @escaping WebServicesManagerCallback) { users.setOrderPhoto(photoId: photoId, order: order, isPrimary: isPrimary, callback: callback) }

    // MARK: - Settings
    func getUserSettings(callback: @escaping WebServicesManagerCallback) { users.getUserSettings(callback: callback) }
    func updateSettings(callback: @escaping WebServicesManagerCallback) { users.updateSettings(callback: callback) }

    // MARK: - Notifications
    func sendNotification(message: String, callback: @escaping WebServicesManagerCallback) { users.sendNotification(message: message, callback: callback) }

    // MARK: - Groups
    func createGroup(friendsIds: String, callback: @escaping WebServicesManagerCallback) { groups.createGroup(friendsIds: friendsIds, callback: callback) }
    func addMember(groupId: Int, friendsId: Int, callback: @escaping WebServicesManagerCallback) { groups.addMember(groupId: groupId, friendsId: friendsId, callback: callback) }
    func myGroup(callback: @escaping WebServicesManagerCallback) { groups.myGroup(callback: callback) }
    func leaveGroup(callback: @escaping WebServicesManagerCallback) { groups.leaveGroup(callback: callback) }
    func acceptGroupInvite(groupId: Int, callback: @escaping WebServicesManagerCallback) { groups.acceptGroupInvite(groupId: groupId, callback: callback) }
    func rejectGroupInvite(groupId: Int, callback: @escaping WebServicesManagerCallback) { groups.rejectGroupInvite(groupId: groupId, callback: callback) }
    func getGroupBy(groupId: Int, callback: @escaping WebServicesManagerCallback) { groups.getGroupBy(groupId: groupId, callback: callback) }

    // MARK: - Matches
    func findGroupsToMatch(page: Int, callback: @escaping WebServicesManagerCallback) { matches.findGroupsToMatch(page: page, callback: callback) }
    func likeTheGroup(groupId: String, callback: @escaping WebServicesManagerCallback) { matches.likeTheGroup(groupId: groupId, callback: callback) }
    func unLikeTheGroup(groupId: String, callback: @escaping WebServicesManagerCallback) { matches.unLikeTheGroup(groupId: groupId, callback: callback) }
    func matchList(callback: @escaping WebServicesManagerCallback) { matches.matchList(callback: callback) }
    func unMatchTheGroup(groupId: String, callback: @escaping WebServicesManagerCallback) { matches.unMatchTheGroup(groupId: groupId, callback: callback) }

    // MARK: - Friendships
    func directFriendShip(phoneNumber: String, callback: @escaping WebServicesManagerCallback) { users.directFriendShip(phoneNumber: phoneNumber, callback: callback) }
    func getFriendsList(callback: @escaping WebServicesManagerCallback) { users.getFriendsList(callback: callback) }
    func getFriendsListBy(contacts: String, directFriendship: Bool, callback: @escaping WebServicesManagerCallback) { users.getFriendsListBy(contacts: contacts, directFriendship: directFriendship, callback: callback) }
    func getReceviedRequests(callback: @escaping WebServicesManagerCallback) { users.getReceivedRequests(callback: callback) }
    func getAppContacts(callback: @escaping WebServicesManagerCallback) { users.getAppContacts(callback: callback) }
    func getFriendsAndInvited(contacts: String, callback: @escaping WebServicesManagerCallback) { users.getFriendsAndInvited(contacts: contacts, callback: callback) }
    func sendRequest(frendId: Int, callback: @escaping WebServicesManagerCallback) { users.sendRequest(friendId: frendId, callback: callback) }
    func acceptRequest(frendId: Int, callback: @escaping WebServicesManagerCallback) { users.acceptRequest(friendId: frendId, callback: callback) }
    func blockFriend(frendId: Int, reason: String? = nil, abusiveMsg: UIImage? = nil, callback: @escaping WebServicesManagerCallback) { users.blockFriend(friendId: frendId, reason: reason, abusiveMsg: abusiveMsg, callback: callback) }
    func unFriend(frendId: Int, callback: @escaping WebServicesManagerCallback) { users.unFriend(friendId: frendId, callback: callback) }
    func getBlockedFriends(callback: @escaping WebServicesManagerCallback) { users.getBlockedFriends(callback: callback) }
    func unblockedTheUsers(block_users: String, callback: @escaping WebServicesManagerCallback) { users.unblockedUsers(blockUserIds: block_users, callback: callback) }
    func checkUserFriendStatus(frendId: Int, callback: @escaping WebServicesManagerCallback) { users.checkUserFriendStatus(friendId: frendId, callback: callback) }

    // MARK: - Device
    func registerForNotificationsWith(fcmToken: String, callback: @escaping WebServicesManagerCallback) { users.registerForNotifications(fcmToken: fcmToken, callback: callback) }
    func sendLastMessageNotification(lastMsg: String, matchId: Int, fcmToken: [String], msgGroup: Int, callback: @escaping WebServicesManagerCallback) { users.sendLastMessageNotification(lastMsg: lastMsg, matchId: matchId, fcmToken: fcmToken, msgGroup: msgGroup, callback: callback) }
}

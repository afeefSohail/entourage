// UserRepository.swift — auth, profile, photos, settings, device, friendships
import Foundation
import UIKit
import Alamofire

protocol UserRepositoryProtocol {
    // Auth / profile
    func checkUpdatetion(callback: @escaping RepoCallback)
    func userSignUp(phoneNum: String, callback: @escaping RepoCallback)
    func getUser(callback: @escaping RepoCallback)
    func getUserBy(phoneNum: String, callback: @escaping RepoCallback)
    func editUserProfile(checkAge: Bool, callback: @escaping RepoCallback)
    func checkUserNameAvailability(userName: String, callback: @escaping RepoCallback)
    func deleteUserAccount(reason: String, callback: @escaping RepoCallback)
    func updateLocation(callback: @escaping RepoCallback)
    func searchBy(userName: String, callback: @escaping RepoCallback)
    func reportUser(userVM: UserViewModel, reason: String, image: UIImage, callback: @escaping RepoCallback)
    func sendInviteMessage(phoneNumber: String, callback: @escaping RepoCallback)
    // Photos
    func uploadPhoto(image: Data, isPrimary: Bool, order: Int, callback: @escaping RepoCallback)
    func deletePhoto(photoId: Int, callback: @escaping RepoCallback)
    func setOrderPhoto(photoId: Int, order: Int, isPrimary: Bool, callback: @escaping RepoCallback)
    // Settings
    func getUserSettings(callback: @escaping RepoCallback)
    func updateSettings(callback: @escaping RepoCallback)
    // Notifications / device
    func sendNotification(message: String, callback: @escaping RepoCallback)
    func registerForNotifications(fcmToken: String, callback: @escaping RepoCallback)
    func sendLastMessageNotification(lastMsg: String, matchId: Int, fcmToken: [String], msgGroup: Int, callback: @escaping RepoCallback)
    // Friendships
    func directFriendShip(phoneNumber: String, callback: @escaping RepoCallback)
    func getFriendsList(callback: @escaping RepoCallback)
    func getFriendsListBy(contacts: String, directFriendship: Bool, callback: @escaping RepoCallback)
    func getReceivedRequests(callback: @escaping RepoCallback)
    func getAppContacts(callback: @escaping RepoCallback)
    func getFriendsAndInvited(contacts: String, callback: @escaping RepoCallback)
    func sendRequest(friendId: Int, callback: @escaping RepoCallback)
    func acceptRequest(friendId: Int, callback: @escaping RepoCallback)
    func rejectRequest(friendId: Int, callback: @escaping RepoCallback)
    func blockFriend(friendId: Int, reason: String?, abusiveMsg: UIImage?, callback: @escaping RepoCallback)
    func unFriend(friendId: Int, callback: @escaping RepoCallback)
    func getBlockedFriends(callback: @escaping RepoCallback)
    func unblockedUsers(blockUserIds: String, callback: @escaping RepoCallback)
    func checkUserFriendStatus(friendId: Int, callback: @escaping RepoCallback)
}

final class UserRepository: RepositoryBase, UserRepositoryProtocol {

    static let shared = UserRepository()

    // MARK: - Auth / Profile

    func checkUpdatetion(callback: @escaping RepoCallback) {
        guard let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            callback(nil, nil); return
        }
        let params = ["ios_version": version]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            if let dic = response.value as? [String: Any], let status = dic["is_valid"] as? Bool {
                callback(status, nil)
            } else {
                callback(false, nil)
            }
        }
        session.request(url("/api/v1/users/check_ios_version"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func userSignUp(phoneNum: String, callback: @escaping RepoCallback) {
        let params = ["phone_number": phoneNum]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                EntourageManager.shared.user.saveToken()
                callback(base.user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/user_signup"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getUser(callback: @escaping RepoCallback) {
        let params = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                EntourageManager.shared.user.saveToken()
                callback(base.user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/user_by_auth_token"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getUserBy(phoneNum: String, callback: @escaping RepoCallback) {
        let params = ["phone_number": phoneNum]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                EntourageManager.shared.user.saveToken()
                callback(base.user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/user_by_phone_number"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func editUserProfile(checkAge: Bool, callback: @escaping RepoCallback) {
        let user = EntourageManager.shared.user
        var params: [String: Any] = [
            "auth_token": User.getToken(),
            "gender": user.gender ?? "male",
            "first_name": user.first_name ?? "",
            "user_name": user.user_name ?? "",
            "last_name": user.last_name ?? "",
            "bio": user.bio ?? ""
        ]
        if checkAge { params["dob"] = user.dob ?? "" }
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                callback(base.user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/edit_profile"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func checkUserNameAvailability(userName: String, callback: @escaping RepoCallback) {
        let params = ["user_name": userName.lowercased()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in
            callback("Yes", nil)
        }
        session.request(url("/api/v1/users/user_name_available"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func deleteUserAccount(reason: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "reason": reason]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/users/delete_account"), method: .delete, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func updateLocation(callback: @escaping RepoCallback) {
        let user = EntourageManager.shared.user
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "latitude": user.latitude ?? "",
            "longitude": user.longitude ?? ""
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                callback(base.user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/update_coordinates"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func searchBy(userName: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "user_name": userName]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                var base = try JSONDecoder().decode(BaseFriendShip.self, from: data)
                if let users = base.users, !users.isEmpty {
                    for user in users {
                        user.friendStatus = "no_relation"
                        base.friendships.append(user)
                    }
                }
                base.friendships.removeAll { $0.phone_number == EntourageManager.shared.user.phone_number }
                callback(base.friendships, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/search_by_user_name"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func reportUser(userVM: UserViewModel, reason: String, image: UIImage, callback: @escaping RepoCallback) {
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "user_id": userVM.user.id,
            "reason": reason
        ]
        AF.upload(multipartFormData: { form in
            if let data = image.pngData() {
                form.append(data, withName: "image", fileName: "Report_\(userVM.displayName).png", mimeType: "image/png")
            }
            for (key, value) in params {
                if let s = value as? String { form.append(s.data(using: .utf8)!, withName: key) }
                else if let b = value as? Bool { form.append("\(b)".data(using: .utf8)!, withName: key) }
                else if let i = value as? Int { form.append("\(i)".data(using: .utf8)!, withName: key) }
            }
        }, to: url("/api/v1/users/report"), method: .post)
        .responseJSON { response in
            if response.data != nil { callback(nil, nil) }
            else if let error = response.error { callback(nil, error.localizedDescription) }
        }
    }

    func sendInviteMessage(phoneNumber: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "phone_number": phoneNumber]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback("MessageSend", nil) }
        session.request(url("/api/v1/users/send_message_invite"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    // MARK: - Photos

    func uploadPhoto(image: Data, isPrimary: Bool, order: Int, callback: @escaping RepoCallback) {
        var params: [String: Any] = ["auth_token": User.getToken(), "order": order]
        if isPrimary { params["is_primary"] = isPrimary }
        AF.upload(multipartFormData: { form in
            let index = EntourageManager.shared.photos.count
            form.append(image, withName: "image", fileName: "File\(index).png", mimeType: "image/png")
            for (key, value) in params {
                if let s = value as? String { form.append(s.data(using: .utf8)!, withName: key) }
                else if let b = value as? Bool { form.append("\(b)".data(using: .utf8)!, withName: key) }
                else if let i = value as? Int { form.append("\(i)".data(using: .utf8)!, withName: key) }
            }
        }, to: url("/api/v1/photos/upload_photo"), method: .post)
        .responseJSON { response in
            guard let data = response.data else { callback(nil, nil); return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user.photos = base.user.photos
                EntourageManager.shared.photos = base.user.photos
                callback(base.user, nil)
            } catch { print(error); callback(nil, nil) }
        }
    }

    func deletePhoto(photoId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "id": photoId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                callback(nil, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/photos/delete_photo"), method: .delete, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func setOrderPhoto(photoId: Int, order: Int, isPrimary: Bool, callback: @escaping RepoCallback) {
        var params: [String: Any] = ["auth_token": User.getToken(), "id": photoId, "order": order]
        if isPrimary { params["is_primary"] = isPrimary }
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseUser.self, from: data)
                EntourageManager.shared.user = base.user
                EntourageManager.shared.photos = base.user.photos
                callback(nil, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/photos/set_order"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    // MARK: - Settings

    func getUserSettings(callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let settings = try JSONDecoder().decode(Settings.self, from: data)
                EntourageManager.shared.setting = settings.setting
                callback(settings.setting, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/my_setting"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func updateSettings(callback: @escaping RepoCallback) {
        let setting = EntourageManager.shared.setting
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "everyone": setting?.everyone ?? false,
            "male_only": setting?.male_only ?? false,
            "female_only": setting?.female_only ?? false,
            "min_age": setting?.min_age ?? 18,
            "max_age": setting?.max_age ?? 42,
            "max_distace": setting?.max_distace ?? 50,
            "general": setting?.general ?? false,
            "friendship": setting?.friendship ?? false,
            "match": setting?.match ?? false,
            "group": setting?.group ?? false,
            "chat": setting?.chat ?? false
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let settings = try JSONDecoder().decode(Settings.self, from: data)
                EntourageManager.shared.setting = settings.setting
                callback(EntourageManager.shared.setting, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/users/edit_setting"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    // MARK: - Notifications / Device

    func sendNotification(message: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "user_id": EntourageManager.shared.user.id,
            "message": message
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/notifications/send_notification"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func registerForNotifications(fcmToken: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "physical_address": UIDevice.current.identifierForVendor?.uuidString ?? "",
            "fcm_token": fcmToken,
            "device_type": "iphone"
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/devices/update_device_token"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func sendLastMessageNotification(lastMsg: String, matchId: Int, fcmToken: [String], msgGroup: Int, callback: @escaping RepoCallback) {
        let notification: [String: Any] = [
            "title": "Entouarge",
            "sound": "message.wav",
            "body": "💬 \(EntourageManager.shared.user.first_name ?? "") sent you a Message"
        ]
        let data: [String: Any] = [
            "notifiable_type": "Message",
            "notifiable_id": "\(matchId)",
            "group_id": "\(msgGroup)",
            "message": "💬 \(EntourageManager.shared.user.first_name ?? "") sent you a Message",
            "group_fcm_tokens": fcmToken,
            "notification": notification
        ]
        let params: [String: Any] = ["data": data]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            if response.data != nil { callback("Success", nil) }
        }
        session.request("https://us-east1-entourage-12345.cloudfunctions.net/sendNotificationToUsers",
                        method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    // MARK: - Friendships

    func directFriendShip(phoneNumber: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "phone_number": phoneNumber]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let f = try JSONDecoder().decode(FriendShip.self, from: data)
                callback(f.friendship_user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/direct_friendship"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getFriendsList(callback: @escaping RepoCallback) {
        let params = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseFriendShip.self, from: data)
                EntourageManager.shared.FriendShips = base.friendships
                callback(base.friendships, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/friendes"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getFriendsListBy(contacts: String, directFriendship: Bool, callback: @escaping RepoCallback) {
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "phone_numbers": contacts,
            "direct_friendship": directFriendship
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                var base = try JSONDecoder().decode(BaseFriendShip.self, from: data)
                if let users = base.users, !users.isEmpty {
                    for user in users {
                        user.friendStatus = "Request"
                        base.friendships.append(user)
                    }
                }
                callback(base.friendships, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/all_friends_and_requests"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getReceivedRequests(callback: @escaping RepoCallback) {
        let params = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let req = try JSONDecoder().decode(RequestFriends.self, from: data)
                callback(req.friendships, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/received_requests"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getAppContacts(callback: @escaping RepoCallback) {
        let params = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                var contacts = try JSONDecoder().decode(RequestFriends.self, from: data)
                contacts.friendships.removeAll { $0.phone_number == EntourageManager.shared.user.phone_number }
                callback(contacts.friendships, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/no_relation"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getFriendsAndInvited(contacts: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "phone_numbers": contacts]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                var result = try JSONDecoder().decode(FriendsWithInvitedUser.self, from: data)
                result.friendships.removeAll { $0.phone_number == EntourageManager.shared.user.phone_number }
                callback(result, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/friends_and_no_relation"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func sendRequest(friendId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "friend_id": friendId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let f = try JSONDecoder().decode(FriendShip.self, from: data)
                callback(f.friendship_user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/request"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func acceptRequest(friendId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "friend_id": friendId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let f = try JSONDecoder().decode(FriendShip.self, from: data)
                callback(f.friendship_user, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/accept"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func rejectRequest(friendId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "friend_id": friendId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/friendships/reject"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func blockFriend(friendId: Int, reason: String? = nil, abusiveMsg: UIImage? = nil, callback: @escaping RepoCallback) {
        var params: [String: Any] = ["auth_token": User.getToken(), "friend_id": friendId]
        if reason != nil { params["reason"] = "Abusive content." }
        AF.upload(multipartFormData: { form in
            if let data = abusiveMsg?.pngData() {
                form.append(data, withName: "image", fileName: "Block_\(friendId)).png", mimeType: "image/png")
            }
            for (key, value) in params {
                if let s = value as? String { form.append(s.data(using: .utf8)!, withName: key) }
                else if let b = value as? Bool { form.append("\(b)".data(using: .utf8)!, withName: key) }
                else if let i = value as? Int { form.append("\(i)".data(using: .utf8)!, withName: key) }
            }
        }, to: url("/api/v1/friendships/block"), method: .post)
        .responseJSON { response in
            if let data = response.data {
                do {
                    let f = try JSONDecoder().decode(FriendShip.self, from: data)
                    callback(f.friendship_user, nil)
                } catch { print(error) }
            } else if let error = response.error {
                callback(nil, error.localizedDescription)
            }
        }
    }

    func unFriend(friendId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "friend_id": friendId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/friendships/unfriend"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getBlockedFriends(callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(BaseFriendShip.self, from: data)
                callback(base.friendships, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/friendships/blocked"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func unblockedUsers(blockUserIds: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "blocked_user_ids": blockUserIds]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/friendships/unblock"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func checkUserFriendStatus(friendId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "friend_id": friendId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let dict = response.value as? [String: Any] else { callback(nil, nil); return }
            callback(dict["status"] as? String, nil)
        }
        session.request(url("/api/v1/friendships/status"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }
}

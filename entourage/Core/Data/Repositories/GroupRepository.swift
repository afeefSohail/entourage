// GroupRepository.swift — group CRUD and member management
import Foundation
import Alamofire

protocol GroupRepositoryProtocol {
    func createGroup(groupStatusId: Int, friendsIds: String, callback: @escaping RepoCallback)
    func addMember(groupId: Int, friendsId: Int, callback: @escaping RepoCallback)
    func myGroup(callback: @escaping RepoCallback)
    func leaveGroup(callback: @escaping RepoCallback)
    func acceptGroupInvite(groupId: Int, callback: @escaping RepoCallback)
    func rejectGroupInvite(groupId: Int, callback: @escaping RepoCallback)
    func getGroupBy(groupId: Int, callback: @escaping RepoCallback)
}

final class GroupRepository: RepositoryBase, GroupRepositoryProtocol {

    static let shared = GroupRepository()

    func createGroup(groupStatusId: Int, friendsIds: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "friend_ids": friendsIds,
            "group_status_id": groupStatusId
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(MyGroup.self, from: data)
                EntourageManager.shared.myGroup = base.group
                callback(base.group, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/groups/create"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func addMember(groupId: Int, friendsId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = [
            "auth_token": User.getToken(),
            "group_id": groupId,
            "friend_id": friendsId
        ]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(MyGroup.self, from: data)
                EntourageManager.shared.myGroup = base.group
                callback(base.group, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/groups/add_member"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func myGroup(callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(MyGroup.self, from: data)
                if base.group != nil {
                    EntourageManager.shared.myGroup = base.group
                    callback(EntourageManager.shared.myGroup, nil)
                } else {
                    callback(nil, nil)
                }
            } catch { print(error) }
        }
        session.request(url("/api/v1/groups/my_group"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func leaveGroup(callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/groups/leave_group"), method: .delete, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func acceptGroupInvite(groupId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(MyGroup.self, from: data)
                if let idx = EntourageManager.shared.groupInviteRequestes.lastIndex(where: { $0.id == base.group?.id ?? 0 }) {
                    EntourageManager.shared.groupInviteRequestes.remove(at: idx)
                }
                EntourageManager.shared.myGroup = base.group
                callback(base.group, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/groups/accept_group_invitation"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func rejectGroupInvite(groupId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in
            if let idx = EntourageManager.shared.groupInviteRequestes.lastIndex(where: { $0.id == groupId }) {
                EntourageManager.shared.groupInviteRequestes.remove(at: idx)
            }
            callback(nil, nil)
        }
        session.request(url("/api/v1/groups/reject_group_invitation"), method: .delete, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func getGroupBy(groupId: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let base = try JSONDecoder().decode(MyGroup.self, from: data)
                callback(base.group, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/groups/group_by_id"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }
}

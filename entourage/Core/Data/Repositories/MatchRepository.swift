// MatchRepository.swift — swipe deck, like/unlike, match list, unmatch
import Foundation
import Alamofire

protocol MatchRepositoryProtocol {
    func findGroupsToMatch(page: Int, callback: @escaping RepoCallback)
    func likeTheGroup(groupId: String, callback: @escaping RepoCallback)
    func unLikeTheGroup(groupId: String, callback: @escaping RepoCallback)
    func matchList(callback: @escaping RepoCallback)
    func unMatchTheGroup(groupId: String, callback: @escaping RepoCallback)
}

final class MatchRepository: RepositoryBase, MatchRepositoryProtocol {

    static let shared = MatchRepository()

    func findGroupsToMatch(page: Int, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "page": page]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let otherGroups = try JSONDecoder().decode(OtherGroups.self, from: data)
                otherGroups.groups.forEach { group in
                    if group.users.isEmpty || group.groupStatus == .inactive {
                        if let idx = otherGroups.groups.lastIndex(where: { $0.id == group.id }) {
                            otherGroups.groups.remove(at: idx)
                        }
                    }
                }
                callback(otherGroups, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/matches/find_groups"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func likeTheGroup(groupId: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let likeGroup = try JSONDecoder().decode(MyMatche.self, from: data)
                callback(likeGroup.match, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/matches/like_group"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func unLikeTheGroup(groupId: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let likeGroup = try JSONDecoder().decode(MyMatche.self, from: data)
                callback(likeGroup.match, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/matches/unlike_group"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func matchList(callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let myMatches = try JSONDecoder().decode(MyMatches.self, from: data)
                EntourageManager.shared.myMatchs.removeAll()
                EntourageManager.shared.myMatchs = myMatches.matches
                reOrderTheMatch(Matches: EntourageManager.shared.myMatchs)
                callback(EntourageManager.shared.myMatchs, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/matches/my_matches"), method: .get, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func unMatchTheGroup(groupId: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/matches/unmatch_group"), method: .delete, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }
}

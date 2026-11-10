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
                let res = try JSONDecoder().decode(APIResponse<[Group]>.self, from: data)
                let result = OtherGroups()
                result.groups = (res.data ?? []).filter { !$0.users.isEmpty && $0.groupStatus != .inactive }
                result.pagination.currentPage = res.meta.currentPage
                result.pagination.totalPages  = res.meta.totalPages
                result.pagination.perPage     = res.meta.perPage
                result.pagination.totalCount  = res.meta.totalCount
                callback(result, nil)
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
                let res = try JSONDecoder().decode(APIResponse<Match>.self, from: data)
                callback(res.data, nil)
            } catch { print(error) }
        }
        session.request(url("/api/v1/matches/like_group"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func unLikeTheGroup(groupId: String, callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken(), "group_id": groupId]
        let parsing: (DataResponse<Any, AFError>) -> Void = { _ in callback(nil, nil) }
        session.request(url("/api/v1/matches/unlike_group"), method: .post, parameters: params)
            .validate().responseJSON(completionHandler: handle(parsing: parsing, callback: callback))
    }

    func matchList(callback: @escaping RepoCallback) {
        let params: [String: Any] = ["auth_token": User.getToken()]
        let parsing: (DataResponse<Any, AFError>) -> Void = { response in
            guard let data = response.data else { return }
            do {
                let res = try JSONDecoder().decode(APIResponse<[Match]>.self, from: data)
                let list = res.data ?? []
                EntourageManager.shared.myMatchs = list
                reOrderTheMatch(Matches: EntourageManager.shared.myMatchs)
                callback(list, nil)
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

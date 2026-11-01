// NetworkCore.swift — shared networking helpers for all repositories
import Foundation
import UIKit
import Alamofire

typealias RepoCallback = (_ result: Any?, _ error: String?) -> Void

fileprivate typealias AlamofireCallback = (DataResponse<Any, AFError>) -> Void

class RepositoryBase {

    let session: Session

    init(session: Session = AF) {
        self.session = session
    }

    func url(_ relative: String) -> String {
        return Constants.baseURL + relative
    }

    func handle(
        parsing parsingHandler: @escaping AlamofireCallback,
        callback: @escaping RepoCallback
    ) -> AlamofireCallback {
        return { response in
            switch response.result {
            case .success:
                parsingHandler(response)
            case .failure:
                callback(nil, self.errorString(from: response.data))
            }
        }
    }

    private func errorString(from data: Data?) -> String {
        guard let data = data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: AnyObject],
              let message = json["error"] as? String else {
            return "Something went wrong"
        }
        return message
    }
}

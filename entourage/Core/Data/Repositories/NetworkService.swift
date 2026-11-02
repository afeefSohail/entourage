// NetworkService.swift — generic async/await network layer
// Wraps Alamofire; decodes APIResponse<T> and returns T directly.
// Usage:
//   let user: User = try await NetworkService.shared.request("/api/v1/users/profile", method: .get)
import Foundation
import Alamofire

// MARK: - Protocol

protocol NetworkServiceProtocol {
    func request<T: Decodable>(_ path: String, method: HTTPMethod, params: [String: Any]) async throws -> T
    func request<T: Decodable>(_ path: String, method: HTTPMethod) async throws -> T
}

// MARK: - Errors

enum NetworkError: LocalizedError {
    case serverError(String)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .serverError(let msg): return msg
        case .decodingError(let err): return err.localizedDescription
        case .unknown: return "Something went wrong"
        }
    }
}

// MARK: - Service

final class NetworkService: NetworkServiceProtocol {

    static let shared = NetworkService()

    private let session: Session

    private init() {
        let interceptor = AuthInterceptor()
        self.session = Session(interceptor: interceptor)
    }

    // MARK: - Generic request

    func request<T: Decodable>(_ path: String,
                               method: HTTPMethod,
                               params: [String: Any] = [:]) async throws -> T {
        let fullURL = Constants.baseURL + path
        var allParams = params
        allParams["auth_token"] = User.getToken()

        return try await withCheckedThrowingContinuation { (cont: CheckedContinuation<T, Error>) in
            session
                .request(fullURL, method: method, parameters: allParams)
                .validate()
                .responseData { response in
                    switch response.result {
                    case .success(let data):
                        do {
                            let decoded = try JSONDecoder().decode(APIResponse<T>.self, from: data)
                            cont.resume(returning: decoded.data)
                        } catch {
                            cont.resume(throwing: NetworkError.decodingError(error))
                        }
                    case .failure:
                        let message = Self.errorMessage(from: response.data)
                        cont.resume(throwing: NetworkError.serverError(message))
                    }
                }
        }
    }

    func request<T: Decodable>(_ path: String, method: HTTPMethod) async throws -> T {
        try await request(path, method: method, params: [:])
    }

    // MARK: - Helpers

    private static func errorMessage(from data: Data?) -> String {
        guard let data,
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let msg = json["error"] as? String else {
            return "Something went wrong"
        }
        return msg
    }
}

// MARK: - Auth interceptor (adds token to every request header as fallback)

private final class AuthInterceptor: RequestInterceptor {
    func adapt(_ urlRequest: URLRequest,
               for session: Session,
               completion: @escaping (Result<URLRequest, Error>) -> Void) {
        completion(.success(urlRequest))
    }
}

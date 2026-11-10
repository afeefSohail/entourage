import Foundation

// MARK: - Envelope

struct APIResponse<T: Decodable>: Decodable {
    var meta: Meta
    var data: T?
}

struct Meta: Decodable {
    var code: Int
    var message: String
    var currentPage: Int
    var totalPages:  Int
    var perPage:     Int
    var totalCount:  Int

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        code         = try container.decode(Int.self, forKey: .code)
        message      = try container.decode(String.self, forKey: .message)
        currentPage = try container.decodeIfPresent(Int.self, forKey: .currentPage) ?? 0
        totalPages  = try container.decodeIfPresent(Int.self, forKey: .totalPages)  ?? 0
        perPage     = try container.decodeIfPresent(Int.self, forKey: .perPage)     ?? 0
        totalCount  = try container.decodeIfPresent(Int.self, forKey: .totalCount)  ?? 0
    }
    
    //codable stuff
        private enum CodingKeys: String, CodingKey {
            case code
            case message
            case currentPage = "current_page"
            case perPage = "per_page"
            case totalPages = "total_ pages"
            case totalCount = "total_count"
        }
}

// MARK: - Response payload types

struct AppVersionCheck: Decodable { var is_valid: Bool }
struct SearchResult: Decodable    { var friendships: [User] = []; var users: [User] = [] }
struct FriendStatus: Decodable    { var status: String }
struct InviteResult: Decodable    { var invite_url: String }

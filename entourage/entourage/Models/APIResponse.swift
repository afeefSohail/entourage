import Foundation

// MARK: - Envelope

struct APIResponse<T: Decodable>: Decodable {
    var meta: Meta
    var data: T?
}

struct Meta: Decodable {
    var code: Int
    var message: String
    var current_page: Int
    var total_pages:  Int
    var per_page:     Int
    var total_count:  Int

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        code         = try c.decode(Int.self, forKey: .code)
        message      = try c.decode(String.self, forKey: .message)
        current_page = try c.decodeIfPresent(Int.self, forKey: .current_page) ?? 0
        total_pages  = try c.decodeIfPresent(Int.self, forKey: .total_pages)  ?? 0
        per_page     = try c.decodeIfPresent(Int.self, forKey: .per_page)     ?? 0
        total_count  = try c.decodeIfPresent(Int.self, forKey: .total_count)  ?? 0
    }
}

// MARK: - Response payload types

struct AppVersionCheck: Decodable { var is_valid: Bool }
struct SearchResult: Decodable    { var friendships: [User] = []; var users: [User] = [] }
struct FriendStatus: Decodable    { var status: String }
struct InviteResult: Decodable    { var invite_url: String }

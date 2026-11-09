import Foundation

// MARK: - Envelope

struct APIResponse<T: Decodable>: Decodable {
    var meta: Meta
    var data: T?
}

struct Meta: Decodable {
    var code: Int
    var message: String
    var current_page: Int = 0
    var total_pages:  Int = 0
    var per_page:     Int = 0
    var total_count:  Int = 0
}

// MARK: - Response payload types

struct AppVersionCheck: Decodable { var is_valid: Bool }
struct SearchResult: Decodable    { var friendships: [User] = []; var users: [User] = [] }
struct FriendStatus: Decodable    { var status: String }
struct InviteResult: Decodable    { var invite_url: String }

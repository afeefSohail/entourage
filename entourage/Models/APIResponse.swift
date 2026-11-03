import Foundation

struct APIResponse<T: Decodable>: Decodable {
    var meta: Meta
    var data: T?
}

struct Meta: Decodable {
    var code: Int
    var message: String
}

// FriendViewModel.swift — presentation wrapper for a User in a friendship context
import Foundation

struct FriendViewModel {

    let user: User

    init(_ user: User) {
        self.user = user
    }

    // MARK: - Name

    var displayName: String  { user.first_name ?? "" }
    var fullName: String {
        let first = user.first_name ?? ""
        let last  = user.last_name  ?? ""
        return last.isEmpty ? first : "\(first) \(last)"
    }
    var initials: String {
        return "\(user.first_name?.prefix(1) ?? "")\(user.last_name?.prefix(1) ?? "")"
    }
    
    var username: String { "@\(user.user_name ?? "")" }

    // MARK: - Age / Bio

    var ageText: String  { "\(user.age ?? 0)" }
    var nameWithAge: String { "\(displayName), \(ageText)" }
    var bioText: String  { user.bio ?? "" }
    var hasBio: Bool     { !bioText.isEmpty }

    // MARK: - Photo

    var primaryPhotoURL: URL? {
        let urlStr = user.mediumPhotoURL
        return urlStr.isEmpty ? nil : URL(string: urlStr)
    }

    var primaryPhotoThumbURL: URL? {
        let urlStr = user.thumbnailURL
        return urlStr.isEmpty ? nil : URL(string: urlStr)
    }

    var hasPhoto: Bool { user.photos.count > 0 }

    // MARK: - Location

    var locationText: String {
        let city  = user.city  ?? ""
        let state = user.state ?? ""
        if city.isEmpty && state.isEmpty { return "" }
        if city.isEmpty  { return state }
        if state.isEmpty { return city }
        return "\(city), \(state)"
    }

    // MARK: - Status

    var isFriend: Bool   { user.friendStatus == "accepted" }
    var isPending: Bool  { user.friendStatus == "pending" }
    var isBlocked: Bool  { user.isBlocked ?? false }
    var isMember: Bool   { user.isMember }
}

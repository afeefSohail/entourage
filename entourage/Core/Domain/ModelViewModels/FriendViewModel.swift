// FriendViewModel.swift — presentation wrapper for a single Friend model
import Foundation

struct FriendViewModel {

    let friend: Friend

    init(_ friend: Friend) {
        self.friend = friend
    }

    // MARK: - Name

    var displayName: String  { friend.first_name ?? "" }
    var fullName: String {
        let first = friend.first_name ?? ""
        let last  = friend.last_name  ?? ""
        return last.isEmpty ? first : "\(first) \(last)"
    }
    var initials: String {
        return "\(friend.first_name?.prefix(1) ?? "")\(friend.last_name?.prefix(1) ?? "")"
    }
    
    var username: String { "@\(friend.user_name ?? "")" }

    // MARK: - Age / Bio

    var ageText: String  { "\(friend.age ?? 0)" }
    var nameWithAge: String { "\(displayName), \(ageText)" }
    var bioText: String  { friend.bio ?? "" }
    var hasBio: Bool     { !bioText.isEmpty }

    // MARK: - Photo

    var primaryPhotoURL: URL? {
        let urlStr = friend.getPrimaryImageMedium()
        return urlStr.isEmpty ? nil : URL(string: urlStr)
    }

    var primaryPhotoThumbURL: URL? {
        var urlStr = ""
        
        if friend.photos.count > 0{
            let primaryImage = friend.photos.filter({$0.is_primary == true})
            if primaryImage.count > 0{
                urlStr = primaryImage[0].thumb ?? ""
            }
        }
                
        return urlStr.isEmpty ? nil : URL(string: urlStr)
    }

    var hasPhoto: Bool { friend.photos.count > 0 }

    // MARK: - Location

    var locationText: String {
        let city  = friend.city  ?? ""
        let state = friend.state ?? ""
        if city.isEmpty && state.isEmpty { return "" }
        if city.isEmpty  { return state }
        if state.isEmpty { return city }
        return "\(city), \(state)"
    }

    // MARK: - Status

    var isFriend: Bool   { friend.status == "accepted" }
    var isPending: Bool  { friend.status == "pending" }
    var isBlocked: Bool  { friend.isBlocked ?? false }
    var isMember: Bool   { friend.isMember }
}

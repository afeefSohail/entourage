// UserViewModel.swift — presentation wrapper for a single User model
import Foundation
import UIKit

struct UserViewModel {

    let user: User

    init(_ user: User) {
        self.user = user
    }

    var displayName: String { user.first_name ?? "" }

    var fullName: String {
        let first = user.first_name ?? ""
        let last  = user.last_name  ?? ""
        return last.isEmpty ? first : "\(first) \(last)"
    }

    var ageText: String { "\(user.age ?? 0)" }

    var nameWithAge: String { "\(displayName), \(ageText)" }

    var username: String { "@\(user.user_name ?? "")" }

    var bioText: String { user.bio ?? "" }
    var hasBio: Bool { !bioText.isEmpty }

    var primaryPhotoURL: URL? {
        guard let photo = user.photos.first(where: { $0.is_primary == true }),
              let urlString = photo.medium else { return nil }
        return URL(string: urlString)
    }

    var isCurrentUser: Bool { user.id == EntourageManager.shared.user.id }
}

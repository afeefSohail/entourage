//  entourage
//

import Foundation


struct FriendsWithInvitedUser : Codable {
    
    var friendships : [User] = []
    var nonExisting : [String] = []
    
    enum CodingKeys: String, CodingKey {
        case friendships = "friendships"
        case nonExisting = "non_existing"
    }

}

struct DirectFriendshipResult: Codable {
    var user: User?
    var invite_url: String?
}



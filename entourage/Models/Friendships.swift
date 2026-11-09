//  entourage
//

import Foundation


struct BaseFriendShip : Codable {
    var friendships : [User] = []
    var users : [User]? = []
}

struct FriendsWithInvitedUser : Codable {
    
    var friendships : [User] = []
    var nonExisting : [String] = []
    
    enum CodingKeys: String, CodingKey {
        case friendships = "friendships"
        case nonExisting = "non_existing"
    }

}

struct RequestFriends : Codable {
    
    var friendships : [User] = []
    
    enum CodingKeys: String, CodingKey {

        case friendships = "friendships"
    }

}

struct FriendShip : Codable {
    var friendship_user = User()
}

struct DirectFriendshipResult: Codable {
    var user: User?
    var invite_url: String?
}


struct SerachFriends : Codable{
    var users : [User] = []
}

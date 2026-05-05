//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.

import Foundation


struct BaseFriendShip : Codable {
    var friendships : [Friend] = []
    var users : [User]? = []
}

struct FriendsWithInvitedUser : Codable {
    
    var friendships : [Friend] = []
    var nonExisting : [String] = []
    
    enum CodingKeys: String, CodingKey {
        case friendships = "friendships"
        case nonExisting = "non_existing"
    }

}

struct RequestFriends : Codable {
    
    var friendships : [Friend] = []
    
    enum CodingKeys: String, CodingKey {

        case friendships = "friendships"
    }

}

struct FriendShip : Codable {
    var friendship_user = Friend()
}


struct SerachFriends : Codable{
    var users : [User] = []
}

//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.

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


struct SerachFriends : Codable{
    var users : [User] = []
}

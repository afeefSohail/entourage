//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.


import UIKit

class BaseUser : Codable {
    var user = User()
}

class User : Codable {

    var id                   : Int     = 0
    var phone_number         : String? = ""
    var user_name            : String? = ""
    var bio                  : String? = ""
    var first_name           : String? = ""
    var last_name            : String? = ""
    var latitude             : String? = ""
    var longitude            : String? = ""
    var dob                  : Int?    = 0
    var age                  : Int?    = 0
    var gender               : String? = ""
    var city                 : String? = ""
    var state                : String? = ""
    var photos               : [Photo] = []
    var fcm_tokens           : [String]? = []
    var isMember             = false
    var isBlocked            : Bool?   = false
    var authentication_token : String? = ""

    enum CodingKeys: String, CodingKey {
        case id
        case phone_number         = "phone_number"
        case authentication_token = "authentication_token"
        case user_name            = "user_name"
        case bio
        case first_name           = "first_name"
        case last_name            = "last_name"
        case latitude
        case longitude
        case dob
        case gender
        case city
        case state
        case photos
        case age
        case fcm_tokens
        case isBlocked            = "is_blocked"
    }

    func saveToken() {
        UserDefaults.standard.set(authentication_token, forKey: "token")
    }

    static func getToken() -> String {
        if let token = UserDefaults.standard.object(forKey: "token") as? String {
            return token
        }
        return ""
    }

    func name() -> String {
        return "\(String(first_name ?? ""))"
    }

    func getChatUser(sideId: Int) -> ChatUser {
        let charUser = ChatUser(id: "\(self.id)", displayName: self.first_name ?? "", photoUrl: self.mediumPhotoURL, isAnonymous: false, groupId: sideId)
        return charUser
    }

    func removeToken() {
        UserDefaults.standard.removeObject(forKey: "token")
    }

    static func needsLogin() -> Bool {
        return UserDefaults.standard.object(forKey: "token") == nil
    }

    static func userFriend(user: Friend) -> User {
        let newUser = User()
        newUser.id                   = user.id
        newUser.phone_number         = user.phone_number ?? ""
        newUser.authentication_token = user.authentication_token ?? ""
        newUser.user_name            = user.user_name ?? ""
        newUser.bio                  = user.bio ?? ""
        newUser.first_name           = user.first_name ?? ""
        newUser.last_name            = user.last_name ?? ""
        newUser.latitude             = user.latitude ?? ""
        newUser.longitude            = user.longitude ?? ""
        newUser.photos               = user.photos
        newUser.fcm_tokens           = user.fcm_tokens
        newUser.isMember             = user.isMember
        newUser.isBlocked            = user.isBlocked ?? false
        return newUser
    }
}

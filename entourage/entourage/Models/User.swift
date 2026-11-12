//  entourage
//

import UIKit


class User : Codable {

    var id                   : Int     = 0
    var phoneNumber         : String? = ""
    var userName            : String? = ""
    var bio                  : String? = ""
    var firstName           : String? = ""
    var lastName            : String? = ""
    var latitude             : String? = ""
    var longitude            : String? = ""
    var dob                  : Int?    = 0
    var age                  : Int?    = 0
    var gender               : String? = ""
    var city                 : String? = ""
    var state                : String? = ""
    var photos               : [Photo] = []
    var fcmTokens           : [String]? = []
    var isMember             = false
    var isBlocked            : Bool?   = false
    var authenticationToken : String? = ""
    var friendStatus         : String? = nil

    enum CodingKeys: String, CodingKey {
        case id
        case phoneNumber         = "phone_number"
        case authenticationToken = "authentication_token"
        case userName            = "user_name"
        case bio
        case firstName           = "first_name"
        case lastName            = "last_name"
        case latitude
        case longitude
        case dob
        case gender
        case city
        case state
        case photos
        case age
        case fcmTokens
        case isBlocked            = "is_blocked"
        case friendStatus         = "status"
    }

    func saveToken() {
        UserDefaults.standard.set(authenticationToken, forKey: "token")
    }

    static func getToken() -> String {
        if let token = UserDefaults.standard.object(forKey: "token") as? String {
            return token
        }
        return ""
    }

    func name() -> String {
        return "\(String(firstName ?? ""))"
    }

    func getChatUser(sideId: Int) -> ChatUser {
        let charUser = ChatUser(id: "\(self.id)", displayName: self.firstName ?? "", photoUrl: self.mediumPhotoURL, isAnonymous: false, groupId: sideId)
        return charUser
    }

    func removeToken() {
        UserDefaults.standard.removeObject(forKey: "token")
    }

    static func needsLogin() -> Bool {
        return UserDefaults.standard.object(forKey: "token") == nil
    }

}

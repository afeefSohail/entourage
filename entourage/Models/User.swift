//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.


import UIKit

class BaseUser : Codable {
    
    var user = User()
    
}


class User : Codable {
    
    var id : Int = 0
    var phone_number : String? = ""
    var authentication_token : String? = ""
    var user_name : String? = ""
    var bio : String? = ""
    var first_name : String? = ""
    var last_name : String? = ""
    var latitude : String? = ""
    var longitude : String? = ""
    var dob : Int? = 0
    var age : Int? = 0
    var gender : String? = ""
    var city : String? = ""
    var state : String? = ""
    var photos : [Photo] = []
    var fcm_tokens : [String]? = []
    var pendingGroupInvitation : [Group]?  = []
    var isMember = false
    var instantMatchAllow : Int? = 0
    var spotLightAllow : Int? = 0
    var isBlocked : Bool? = false
    
    enum CodingKeys: String, CodingKey{
        
        case id = "id"
        case phone_number = "phone_number"
        case authentication_token = "authentication_token"
        case user_name = "user_name"
        case bio = "bio"
        case first_name = "first_name"
        case last_name = "last_name"
        case latitude = "latitude"
        case longitude = "longitude"
        case dob = "dob"
        case gender = "gender"
        case city = "city"
        case state = "state"
        case photos = "photos"
        case age
        case fcm_tokens
        case pendingGroupInvitation = "pending_group_invitation"
        case instantMatchAllow = "instant_match_allow"
        case spotLightAllow = "spot_light_allow"
        case isBlocked = "is_blocked"
    }
    
    func saveToken(){
        UserDefaults.standard.set(authentication_token, forKey: "token")
    }
    
    static func getToken()->String{
        if let token  = UserDefaults.standard.object(forKey: "token") as? String{
            return token
        }
        return ""
    }
    
    func surname()->String{
        return "\(first_name ?? "") \(last_name ?? "")"
    }
    
    func name()->String{
        return "\(String(first_name ?? ""))"
    }
    func checkUserInfo()->String{
        
        // this needs to be handle from backend, so ask faisal to send username as empty instead of number
        let phNumber = self.phone_number!
        let defaultName = String(phNumber.dropFirst())
        
        if self.age == nil || self.age ?? 0 == 0{
            return "Gender"
        }else if self.photos.isEmpty == true{
            return "Photos"
        }else if self.user_name == defaultName {
            return "userName"
        }
        
        return "Main"
    }
    
    func getChatUser(sideId:Int)->ChatUser{
        let charUser = ChatUser(id: "\(self.id)" , displayName: self.first_name  ?? "" , photoUrl: self.getPrimaryImageMedium() , isAnonymous: false , groupId: sideId)
    
        return charUser
    }
    
    func removeToken(){
        UserDefaults.standard.removeObject(forKey: "token")
    }
    
    static func needsLogin()->Bool{
        if UserDefaults.standard.object(forKey: "token") != nil {
            return false
        }
        return true
    }

    func getPrimaryImageThumb()->String{
        
        if self.photos.count > 0{
            let primaryImage = self.photos.filter({$0.is_primary == true})
            if primaryImage.count > 0{
                   return primaryImage[0].thumb ?? ""
            }
        }
        
        return ""
    }

    func getPrimaryImageMedium()->String{
        
        if self.photos.count > 0{
            let primaryImage = self.photos.filter({$0.is_primary == true})
            if primaryImage.count > 0{
                return primaryImage[0].medium ?? ""
            }
        }
        
        return ""
    }

    func getPrimaryImageOriginal()->String{
        
        if self.photos.count > 0{
            let primaryImage = self.photos.filter({$0.is_primary == true})
            if primaryImage.count > 0{
                return primaryImage[0].original ?? ""
            }
        }
        
        return ""
    }

    static func userFriend(user:Friend)->User{
        
        let newUser = User()
        newUser.id = user.id
        newUser.phone_number = user.phone_number ?? ""
        newUser.authentication_token = user.authentication_token ?? ""
        newUser.user_name = user.user_name ?? ""
        newUser.bio = user.bio ?? ""
        newUser.first_name = user.first_name ?? ""
        newUser.last_name = user.last_name ?? ""
        newUser.latitude = user.latitude ?? ""
        newUser.longitude = user.longitude ?? ""
        newUser.photos = user.photos
        newUser.fcm_tokens = user.fcm_tokens
        newUser.pendingGroupInvitation = user.pendingGroupInvitation
        newUser.isMember = user.isMember
        newUser.instantMatchAllow = user.instantMatchAllow ?? 0
        newUser.spotLightAllow = user.spotLightAllow ?? 0
        newUser.isBlocked = user.isBlocked ?? false

        return newUser

    }
    
    
}

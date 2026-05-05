//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.


import Foundation
struct Friend : Codable {
    
    var contactType : String? = ""
    var id : Int = 0
    var phone_number : String? = ""
    var authentication_token : String? = ""
    var user_name : String? = ""
    var bio : String? = ""
    var status : String?
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
        case status = "status"

    }

    func nameInitials()->String{
        return "\(self.first_name?.prefix(1) ?? "")\(self.last_name?.prefix(1) ?? "")"
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

    static func friendUser(user:User,status:String)->Friend{
     
        let object = Friend(contactType: "", id: user.id, phone_number: user.phone_number ?? "", authentication_token: user.authentication_token ?? "", user_name: user.user_name ?? "", bio: user.bio ?? "", status: status, first_name: user.first_name ?? "", last_name: user.last_name ?? "", latitude: user.latitude ?? "", longitude: user.longitude ?? "", dob: user.dob ?? 0, age: user.age ?? 0, gender: user.gender ?? "male", city: user.city ?? "", state: user.state ?? "", photos: user.photos, fcm_tokens: user.fcm_tokens ?? [], pendingGroupInvitation: user.pendingGroupInvitation ?? [], isMember: user.isMember, instantMatchAllow: user.instantMatchAllow ?? 0, spotLightAllow: user.spotLightAllow ?? 0, isBlocked: user.isBlocked ?? false)

        return object
    }
    
        
}

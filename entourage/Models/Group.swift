
//
//  Group.swift
//  entourage
//
//  Created by afeef sohail on 8/3/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

class MyGroup : Codable {
    var group : Group?
}

class OtherGroups : Codable {
    var groups : [Group] = []
    var pagination : Pagination = Pagination()
}

class Group : Codable {
    
    var id : Int = 0
    var status : String = ""
    var groupStatus = GroupStatuses()
    var users : [User] = []
    var invitedUsers : [User]? = []
    var name : String?
    var city : String?
    var state : String?
    var distance : String? = ""
    var instantMatchAllow : Int? = 0
    var spotLightAllow : Int? = 0
    var spotLightEnabled : Bool? = false
    var spotLightRemainingTime : Int? = 0
    var isReported : Bool = false

    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case status
        case groupStatus = "group_status"
        case users = "users"
        case distance = "distance"
        case name = "name"
        case city = "city"
        case state = "state"
        case invitedUsers = "pending_approval"
        case instantMatchAllow = "instant_match_allow"
        case spotLightAllow = "spot_light_allow"
        case spotLightEnabled = "spot_light_enabled"
        case spotLightRemainingTime = "spot_light_time"

    }
    
    func matcherGroupName()->String{
        
        if users.count > 2{
            return "\(users.last?.first_name ?? "") and \(users.count-1) others"
        }else {
            
            return "\(users.first?.first_name ?? "") and \(users.last?.first_name ?? "")"
        }
    }

    func otherGroupName()->String{
        
        if users.count > 2{
            return "\(users.last?.first_name ?? "") & \(users.count-1) others"
        }else {
            
            return "\(users.first?.first_name ?? "") & \(users.last?.first_name ?? "")"
        }
    }

    func cardsGroupName()->String{
        
        if users.count > 2{
            return "\(users.last?.first_name ?? "") & \(users.count-1) Friends"
        }else {
            
            return "\(users.first?.first_name ?? "") & \(users.last?.first_name ?? "")"
        }
    }

    func myGroupName()->String{
        let filterUser = users.filter({EntourageManager.shared.user.id != $0.id})
        if users.count == 2{
            return filterUser[0].name()
        }else if users.count == 3{
            return "\(filterUser[0].name()) and \(filterUser[1].name())"
        }else if users.count == 4{
            return "\(filterUser[0].name()), \(filterUser[1].name()) and \(filterUser[2].name())"
        }
        return ""
    }
    
    func matchGroupName()->String{
        let filterUser = users.filter({EntourageManager.shared.user.id != $0.id})
        if users.count == 2{
            return "\(filterUser[0].name()) & \(filterUser[1].name())"
        }else if users.count == 3{
            return "\(filterUser[0].name()), \(filterUser[1].name()) & \(filterUser[2].name())"
        }else if users.count == 4{
            return "\(filterUser[0].name()), \(filterUser[1].name()), \(filterUser[2].name()) & \(filterUser[3].name())"
        }
        return ""
    }

    func lastMessageObject(message:String,senderId: Int,readCounter:Int)->LastMessage{
        
        var groupIds : [Int] = []
        let mygroup = EntourageManager.shared.myGroup!
        
        if self.id != mygroup.id{
            groupIds.append(self.id)
        }
        
        groupIds.append(mygroup.id)
        
        return LastMessage(lastMessage: message , groupIds: groupIds, senderId: senderId, counter: readCounter )
        
    }
    
    func allGroupMember()->[User]{
        
        var allMember : [User] = []
        self.users.forEach({$0.isMember = true})
        self.invitedUsers?.forEach({$0.isMember = false})
        
        allMember.append(contentsOf: self.users)
        allMember.append(contentsOf: invitedUsers ?? [])
        
        return allMember
    }
    
    func getGroupIconName()->String{
        let genderList = self.users.compactMap({$0.gender})
        let femaleCount = genderList.filter({$0 == "female"}).count
        let mailCount = genderList.filter({$0 == "male"}).count
        if femaleCount == genderList.count || femaleCount > (genderList.count / 2){
            return "\(genderList.count)F"
        }else if mailCount == genderList.count || mailCount > (genderList.count / 2){
            return "\(genderList.count)M"
        }else {
            return "\(genderList.count)O"
        }
        
    }
    
}

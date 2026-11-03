
//
//  Group.swift
//  entourage
//
//  Created by afeef sohail on 8/3/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

enum GroupStatus: String {
    case active   = "active"
    case inactive = "in_active"
}

class MyGroup : Codable {
    var group : Group?
}

struct Pagination: Codable {
    var current_page: Int = 0
    var total_pages:  Int = 0
    var per_page:     Int = 0
    var total_count:  Int = 0
}

class OtherGroups : Codable {
    var groups     : [Group]    = []
    var pagination : Pagination = Pagination()
}

class Group : Codable {

    var id       : Int    = 0
    var status   : String = GroupStatus.inactive.rawValue
    var users    : [User] = []
    var name     : String?
    var city     : String?
    var state    : String?
    var distance : String? = ""
    var isReported : Bool  = false

    enum CodingKeys: String, CodingKey {
        case id
        case status
        case users
        case distance
        case name
        case city
        case state
    }

    var groupStatus: GroupStatus {
        GroupStatus(rawValue: status) ?? .inactive
    }

    func lastMessageObject(message: String, senderId: Int, readCounter: Int) -> LastMessage {
        var groupIds: [Int] = []
        let mygroup = EntourageManager.shared.myGroup!
        if self.id != mygroup.id {
            groupIds.append(self.id)
        }
        groupIds.append(mygroup.id)
        return LastMessage(lastMessage: message, groupIds: groupIds, senderId: senderId, counter: readCounter)
    }
}

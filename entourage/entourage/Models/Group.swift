
//
//  Group.swift
//  entourage
//
//  afeef sohail on 8/3/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

enum GroupStatus: String {
    case active   = "active"
    case inactive = "in_active"
}


struct Pagination: Codable {
    var currentPage: Int
    var totalPages:  Int
    var perPage:     Int
    var totalCount:  Int

    init() {
        currentPage = 0; totalPages = 0; perPage = 0; totalCount = 0
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPage = try container.decodeIfPresent(Int.self, forKey: .currentPage) ?? 0
        totalPages  = try container.decodeIfPresent(Int.self, forKey: .totalPages)  ?? 0
        perPage     = try container.decodeIfPresent(Int.self, forKey: .perPage)     ?? 0
        totalCount  = try container.decodeIfPresent(Int.self, forKey: .totalCount)  ?? 0
    }
    
    //codable stuff
        private enum CodingKeys: String, CodingKey {
            case currentPage = "current_page"
            case perPage = "per_page"
            case totalPages = "total_ pages"
            case totalCount = "total_count"
        }
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

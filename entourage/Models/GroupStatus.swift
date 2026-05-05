//
//  GroupStatus.swift
//  entourage
//
//  Created by afeef sohail on 8/3/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

class GroupStatusBase : Codable {
    var group_statuses : [GroupStatuses] = []
}

class GroupStatus : Codable {
    var group_status : GroupStatuses?
}

class GroupStatuses : Codable {
    
    var id : Int? = 0
    var name : String? = ""
    var icon : String? = ""
    var statusType : String?
        = ""
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
        case icon = "thumb"
        case statusType = "status_type"
    }
    
}

//
//  Match.swift
//  entourage
//
//  Created by afeef sohail on 8/10/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

class MyMatches : Codable {
    var matches : [Match] = []
}

class MyMatche : Codable {
    var match : Match?
}


class Match : Codable  , Equatable{
    
    static func == (lhs: Match, rhs: Match) -> Bool {
        return lhs.matcher?.id == rhs.matcher?.id
    }
    
    var id : Int = 0
    var status : String? = ""
    var distance : Float? = 0.0
    var chat_id : Int = 0
    var matcher : Group? = Group()
    var lastMessage : String? = ""

    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case status = "status"
        case distance = "distance"
        case chat_id = "chat_id"
        case matcher = "matcher"
    }
    
}

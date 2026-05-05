//
//  LastMessage.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit


/// LastMessage
public struct LastMessage {
    
    
    public var lastMessage : String
    public var groupIds : [Int] = []
    public var lastSenderId : Int
    public var chatTotalCounter : Int
    public var createdAt : Double

    // MARK: - Intializers
    public init(lastMessage: String, groupIds: [Int],senderId:Int,counter:Int) {
        self.lastMessage = lastMessage
        self.groupIds = groupIds
        self.lastSenderId = senderId
        self.chatTotalCounter = counter
        self.createdAt = Date().timeIntervalSince1970
    }
    
}

extension LastMessage:Codable{
    
    private enum CodingKeys: String, CodingKey {
        
        case createdAt
        case lastMessage
        case groupIds
        case lastSenderId
        case chatTotalCounter
        
    }
}

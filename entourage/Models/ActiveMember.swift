//
//  ActiveMember.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

public struct ActiveMember {
    
    public var SenderId: String
    public var Active_Status : Bool
    
    // MARK: - Intializers
    public init(senderId:String,status:Bool) {
        self.SenderId = senderId
        self.Active_Status = status
    }

}

extension ActiveMember:Codable{
    
    private enum CodingKeys: String, CodingKey {
        
        case SenderId = "SenderId"
        case Active_Status = "Active_Status"
        
    }
}

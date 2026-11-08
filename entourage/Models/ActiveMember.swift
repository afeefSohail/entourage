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
    public var Active_Status: Bool
    public var fcm_token: String?

    public init(senderId: String, status: Bool, fcmToken: String? = nil) {
        self.SenderId = senderId
        self.Active_Status = status
        self.fcm_token = fcmToken
    }

}

extension ActiveMember: Codable {
    private enum CodingKeys: String, CodingKey {
        case SenderId = "SenderId"
        case Active_Status = "Active_Status"
        case fcm_token = "fcm_token"
    }
}

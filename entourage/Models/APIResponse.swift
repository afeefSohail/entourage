//
//  APIResponse.swift
//  RxCareApp
//
//  Created by afeef sohail on 23/06/2020.
//  Copyright © 2020 Fantechlabs. All rights reserved.
//

import Foundation
/// This is top container for all API responses
/// T will be replaced by actual models
struct APIResponse<T>: Decodable where T: Decodable {
    //meta data
    var meta: Meta
    var data: T
    
    enum CodingKeys: String, CodingKey {
        case meta, data
    }
}


struct Meta: Decodable {
    var code: Int
    var message: String

    enum CodingKeys: String, CodingKey {
        case code, message
    }
}



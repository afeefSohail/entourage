//
//  Photos.swift
//  entourage
//
//  Created by afeef sohail on 7/28/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class UpdatePhoto : Codable {
    var photo = Photo()
}

class Photo : Codable {
    
    var id : Int = 0
    var order : Int? = 0
    var is_primary : Bool? = false
    var original : String? = ""
    var medium : String? = ""
    var thumb : String? = ""
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case order = "order"
        case is_primary = "is_primary"
        case original = "original"
        case medium = "medium"
        case thumb = "thumb"
    }

}


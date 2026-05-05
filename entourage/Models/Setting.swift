//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.

import UIKit

class Settings : Codable {
    
    var setting = Setting()
}

class Setting : Codable {
    
	var everyone : Bool? = false
	var male_only : Bool? = false
	var female_only : Bool? = false
	var min_age : Int? = 18
	var max_age : Int? = 42
	var group_member_count : Int? = 3
	var max_distace : Int? = 50
    var block_member_count : Int? = 0
    var general : Bool? = false
    var friendship : Bool? = false
    var match : Bool? = false
    var group : Bool? = false
    var chat : Bool? = false
    
	enum CodingKeys: String, CodingKey {

		case everyone = "everyone"
		case male_only = "male_only"
		case female_only = "female_only"
		case min_age = "min_age"
		case max_age = "max_age"
		case group_member_count = "group_member_count"
		case max_distace = "max_distace"
        case block_member_count = "block_member_count"
        case general
        case friendship
        case match
        case group
        case chat
        
	}

    static func checkSettingUpdateion(previousGender:String,preSetting:Setting,NewSetting:Setting)->Bool{
        
        var updationStatus = false
        
        if preSetting.everyone != NewSetting.everyone{
            updationStatus = true
        }
        
        if preSetting.male_only != NewSetting.male_only{
            updationStatus = true
        }
        
        if preSetting.female_only != NewSetting.female_only{
            updationStatus = true
        }
        
        if preSetting.min_age != NewSetting.min_age{
            updationStatus = true
        }
        
        if preSetting.max_age != NewSetting.max_age{
            updationStatus = true
        }
        
//        if preSetting.group_member_count != NewSetting.group_member_count{
//            updationStatus = true
//        }
        
        if preSetting.max_distace != NewSetting.max_distace{
            updationStatus = true
        }
        
        if previousGender != EntourageManager.shared.user.gender{
            updationStatus = true
        }

        if preSetting.block_member_count ?? 0 != NewSetting.block_member_count ?? 0{
            updationStatus = true
        }

        if preSetting.general != NewSetting.general{
            updationStatus = true
        }
        if preSetting.friendship != NewSetting.friendship{
            updationStatus = true
        }

        if preSetting.match != NewSetting.match{
            updationStatus = true
        }

        if preSetting.group != NewSetting.group{
            updationStatus = true
        }

        if preSetting.chat != NewSetting.chat{
            updationStatus = true
        }

        
        return updationStatus
    }
    
    func copy(with zone: NSZone? = nil) -> Setting {
        let copy = Setting()
        copy.everyone = self.everyone
        copy.male_only = self.male_only
        copy.female_only = self.female_only
        copy.min_age = self.min_age
        copy.max_age = self.max_age
        copy.group_member_count = self.group_member_count
        copy.max_distace = max_distace
        copy.general = self.general
        copy.friendship = self.friendship
        copy.match = self.match
        copy.chat = self.chat
        copy.group = self.group
        copy.block_member_count = self.block_member_count
        return copy
    }

}

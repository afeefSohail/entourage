//
//  Pagination.swift
//  entourage
//
//  Created by afeef sohail on 18/11/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit



class Pagination : Codable{
    
    var currentPage : Int = 0
    var nextPage : Int = 0
    var previousPage : Int = 0
    var totalPages : Int = 0
    var totalCount : Int = 0

    
    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case nextPage = "next_page"
        case previousPage = "prev_page"
        case totalPages = "total_pages"
        case totalCount = "total_count"
    }
}

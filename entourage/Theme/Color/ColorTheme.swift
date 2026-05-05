//
//  ColorTheme.swift
//  Chatspace-ios
//
//  Created by Furqan Ahmad on 12/06/2019.
//  Copyright © 2019 Hamilton Hitchings. All rights reserved.
//

import UIKit

enum Colors {
    
    case themeColor
    case pinkColor
    case blackColor
    
    case gray1
    case gray2
    case gray3
    case gray4
    case gray5
    
    // 1
    case custom(hexString: String, alpha: Double)
    // 2
    func withAlpha(_ alpha: Double) -> UIColor {
        return self.value.withAlphaComponent(CGFloat(alpha))
    }
}

extension Colors {
    
    var value: UIColor {
        
        var instanceColor = UIColor.clear
        
        switch self {
            
        case .themeColor:
            instanceColor = UIColor(named: "themeColor")!
        case .pinkColor:
            instanceColor = UIColor(named: "pinkColor")!
        case .blackColor:
            instanceColor = UIColor(named: "blackColor")!
            
        case .gray1:
            instanceColor = UIColor(named: "gray1")!
        case .gray2:
            instanceColor = UIColor(named: "gray2")!
        case .gray3:
            instanceColor = UIColor(named: "gray3")!
        case .gray4:
            instanceColor = UIColor(named: "gray4")!
        case .gray5:
            instanceColor = UIColor(named: "gray5")!
            
        case .custom(let hexValue, let opacity):
            instanceColor = UIColor(hexValue).withAlphaComponent(CGFloat(opacity))
            
        }
        return instanceColor
    }
}

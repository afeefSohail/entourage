//
//  UserBannedVC.swift
//  entourage
//
//  Created by MAC on 01/03/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class UserBannedVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var linkLbl: UILabel!
    @IBOutlet weak var userName: UILabel!

    //MARK: - Class Properties
    var user_name = ""
    
    //MARK: - Constructor
    class func loadUserBannedVC(userName:String)->UserBannedVC{
        
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let userBannedVC = storyboard.instantiateViewController(withIdentifier: "UserBannedVC") as! UserBannedVC
        
        userBannedVC.user_name = "@\(userName)"
        
        return userBannedVC
    }

    override func setupGUI() {
        
        userName.text = user_name
        
        let attributedString = NSMutableAttributedString(string: "You have been banned from Entourage for activity that violates our Terms of Use.", attributes: [
          .font: UIFont(name: "HelveticaNeue", size: 16.0)!,
          .foregroundColor: UIColor("#878f96"),
          .kern: 0.0
        ])
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, range: NSRange(location: 26, length: 9))
    
        
            let linkRange = NSRange(location:67 , length: 12)

            
            let linkAttributes : [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor : UIColor("#22323F"), NSAttributedString.Key.underlineStyle : NSUnderlineStyle.single.rawValue]
            
            attributedString.setAttributes(linkAttributes, range: linkRange)

        linkLbl.attributedText = attributedString
    }

    @IBAction func pressTermsServicesBtn(_ sender:Any){
        openBrowserWith(url: "https://www.swipetogether.com/tos")
    }
}

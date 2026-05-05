//
//  AlertVC.swift
//  Hello.
//
//  Created by Furqan Ahmad on 18/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class AlertVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var userIV:UIImageView!
    @IBOutlet weak var blockStatusLbl :UILabel!
    @IBOutlet weak var descLbl:UILabel!
    @IBOutlet weak var userName:UILabel!

    //MARK: - Class Properties
    var user:User?
    var callback:blockOrUnBlock!
    
    override func setupGUI() {
        
        userName.text = user!.user_name ?? ""
        blockStatusLbl.text = user!.isBlocked ?? false  ? "Unblock User" : "Block User"
        descLbl.text = user!.isBlocked ?? false ?
            "In order to view this user and interact with their profile.You must unblock them first."
            : "You will no longer be able to match or view their profile including groups their in."

        if let url = URL(string: user!.getPrimaryImageMedium()) {
//            userIV.kf.indicatorType = .activity
//            userIV.kf.setImage(with: url)
            setupThumnail(url: url, IV: userIV)
        }
    }
    
    override func updateGUI() {
        
    }

    @IBAction func pressConfirm(sender:Any){
        self.dismiss(animated: true) {
            self.callback(true)
        }
    }
    
    @IBAction func pressCancel(sender:Any){
        if user!.isBlocked ?? false == false { //in case of block the user
            self.dismiss(animated: true) {
            }
        }
    }

}

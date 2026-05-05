//
//  CancelInviteVC.swift
//  entourage
//
//  Created by afeef sohail on 10/13/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class CancelInviteVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var mainLbl : UILabel!
    
    var group = EntourageManager.shared.myGroup
    var friendId = 0
    var callback : PressOkay!
    
    //MARK: - Constructor
    class func cancelInviteVC(friendId:Int, callback:@escaping PressOkay)->CancelInviteVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let cancelInviteVC = storyboard.instantiateViewController(withIdentifier: "CancelInviteVC") as! CancelInviteVC
        
        cancelInviteVC.callback = callback
        cancelInviteVC.friendId = friendId
        
        return cancelInviteVC
    }
    
    override func setupGUI() {
     
        if let user = EntourageManager.shared.myGroup?.invitedUsers?.last(where: {$0.id == friendId}){
            mainLbl.text = user.first_name ?? ""
        }
    }
    
    
}

//MARK: - IBActions
extension CancelInviteVC{
    
    @IBAction func confirmBtn(_ sender:UIButton){
        
        self.startAnimation()
        WebServicesManager.shared.deleteInivitation(groupId: group?.id ?? 0, friendId: friendId) { (_, error) in
            self.stopAnimation()
            if error == nil{
                self.callback()
                self.dismiss(animated: true, completion: nil)
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    @IBAction func cancelBtn(_ sender:UIButton){
        
        self.dismiss(animated: true, completion: nil)
    }
    
}

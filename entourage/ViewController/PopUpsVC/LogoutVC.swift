//
//  logoutVC.swift
//  entourage
//
//  Created by afeef sohail on 10/27/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth

class LogoutVC: BaseVC {


    var callback : PressOkay!

    //MARK: - Constructor
    class func logoutVC(callback:@escaping PressOkay)->LogoutVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let logoutVC = storyboard.instantiateViewController(withIdentifier: "LogoutVC") as! LogoutVC
        
        logoutVC.callback = callback
        
        return logoutVC
    }

}

//MARK: - Actions
extension LogoutVC{
    
    @IBAction func pressConfirm(sender:Any){
    
        
        EntourageManager.shared.user.removeToken()
        EntourageManager.shared.FriendShips.removeAll()
        EntourageManager.shared.groupInviteRequestes.removeAll()
        EntourageManager.shared.groupStatuses.removeAll()
        EntourageManager.shared.groupStatuses.removeAll()
        EntourageManager.shared.myGroup = nil
        EntourageManager.shared.setting = nil
        EntourageManager.shared.otherGroups.removeAll()
        EntourageManager.shared.photos.removeAll()
        EntourageManager.shared.myMatchs.removeAll()
        
        Utils.resetVariables()
        
        lastMessageListner?.unsubscribe()
    
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()

        self.callback()
        self.dismiss(animated: true, completion: nil)

    }
}

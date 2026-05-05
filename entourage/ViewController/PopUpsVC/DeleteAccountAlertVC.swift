//
//  DeleteAccountAlertVC.swift
//  entourage
//
//  Created by afeef sohail on 10/27/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth

class DeleteAccountAlertVC: BaseVC {

    //MARK: - IBOutLets
    var callback : PressOkay!

    //MARK: - Constructor
    class func deleteAccountAlertVC(callback:@escaping PressOkay)->DeleteAccountAlertVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let deleteAccountAlertVC = storyboard.instantiateViewController(withIdentifier: "DeleteAccountAlertVC") as! DeleteAccountAlertVC
        
        deleteAccountAlertVC.callback = callback
        
        return deleteAccountAlertVC
    }

}

//MARK: - Actions
extension DeleteAccountAlertVC{
    
    @IBAction func pressConfirm(sender:Any){
        self.dismiss(animated: true) {
            self.callback()
        }
    }
}

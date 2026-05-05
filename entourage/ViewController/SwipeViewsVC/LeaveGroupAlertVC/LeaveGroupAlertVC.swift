//
//  LeaveGroupAlertVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/15/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class LeaveGroupAlertVC: BaseVC {

    
    //MARK: - IBOutLets
    
    //MARK:- Class Properties
    var callback : PressOkay!
    
    //MARK: - Constructor
    class func loadLeaveGroupAlertVC(callback:@escaping PressOkay) -> LeaveGroupAlertVC {
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let leaveGroupAlertVC = storyboard.instantiateViewController(withIdentifier: "LeaveGroupAlertVC") as! LeaveGroupAlertVC
    
        leaveGroupAlertVC.callback = callback
          return leaveGroupAlertVC
    }

    
    override func setupGUI() {
        super.setupGUI()
        
        self.title = "leaveGroup"
    }


    @IBAction func pressConfirm(sender:Any){
        self.startAnimation()
        WebServicesManager.shared.leaveGroup { (response, error) in
            
            if error == nil{

                let id = EntourageManager.shared.myGroup?.id ?? 0
                
                let recentuser = RecentUsers.getSavedRecentUsers() ?? []
            
                
                if EntourageManager.shared.myGroup?.users.count ?? 0 == 2{
                    
                    deleteTheDocument(groupId: "\(id)", completetion: {
                        self.stopAnimation()

                        
                        EntourageManager.shared.reSetAppData()

                        //after removed of all saved data from User Default then we have to save again
                        EntourageManager.shared.user.saveToken()
                        RecentUsers.saveRecentUsers(Users: recentuser)

                        self.restObjects()
                        
                    })
                }else{
                    self.stopAnimation()

                    EntourageManager.shared.reSetAppData()

                    //after removed of all saved data from User Default then we have to save again
                    EntourageManager.shared.user.saveToken()
                    RecentUsers.saveRecentUsers(Users: recentuser)

                    self.restObjects()
                    
                }
                
            }else{
                
                self.stopAnimation()
                self.showAlert(title: "Error" , message: error!)
            }
        }
    }


    fileprivate func restObjects(){

        resetAllUnReadMsg()
        
        EntourageManager.shared.myGroup = nil
        self.callback()
        self.dismiss(animated: true, completion: nil)
    
    }
}

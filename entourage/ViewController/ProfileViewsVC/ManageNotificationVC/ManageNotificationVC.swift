//
//  ManageNotificationVC.swift
//  entourage
//
//  Created by afeef sohail on 1/15/20.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class ManageNotificationVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    let titleArray = ["General", "Friendship" , "Match" ,  "Group" , "Chat Messages"]
    var setting = EntourageManager.shared.setting
    
    //MARK:- Constructor
    class func manageNotificationVC()-> ManageNotificationVC{
        let manageNotificationVC = UIStoryboard(name: "ProfileViews", bundle: nil).instantiateViewController(identifier: "ManageNotificationVC") as! ManageNotificationVC
        
        return manageNotificationVC
    }
    
    override func setupGUI() {
        
        self.setUpNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!]
        
        //NavBar shadow
        //addNavBarShadow()
        self.navigationController?.navigationBar.setSettingNavBarShadow()
        
        self.tableView.allowsMultipleSelection = false
        
    }
    
    override func updateGUI() {
        
        title = "Manage Notifications"
        Utils.currVC = self
    }
    
    fileprivate func checkNotificationStatus(index:Int)->Bool{
        
        if index == 0 , setting?.general == true{
            return true
        }else if index == 1, setting?.friendship == true{
            return true
        }else if index == 2 , setting?.match == true{
            return true
        }else if index == 3 , setting?.group == true{
            return true
        }else if index == 4 , setting?.chat == true{
            return true
        }
        
        return false
        
    }
    
    fileprivate func enableNotification(index:Int){
        
        if index == 0 {
            setting?.general = true
        }else if index == 1{
            setting?.friendship = true
        }else if index == 2 {
            setting?.match = true
        }else if index == 3 {
            setting?.group = true
        }else if index == 4 {
            setting?.chat = true
        }
        
        EntourageManager.shared.setting = setting
        
    }

    fileprivate func disableNotification(index:Int){
        
        if index == 0 {
            setting?.general = false
        }else if index == 1{
            setting?.friendship = false
        }else if index == 2 {
            setting?.match = false
        }else if index == 3 {
            setting?.group = false
        }else if index == 4 {
            setting?.chat = false
        }
        
        EntourageManager.shared.setting = setting
        
    }

}

extension ManageNotificationVC : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ManageNotificationVCCell", for: indexPath) as! OptionCell
        
        cell.filterName.text = titleArray[indexPath.item]
        
        
        if checkNotificationStatus(index: indexPath.item) {
            cell.checkMark.isHidden = false
            enableNotification(index: indexPath.item)
        }else{
            cell.checkMark.isHidden = true
            disableNotification(index: indexPath.item)
        }
        
        
        cell.btmBreakView.isHidden = titleArray.count - 1 == indexPath.item ? false : true
        
        return cell
    }
    
}

//MARK: - UITableViewDelegate
extension ManageNotificationVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
                
        let cell = tableView.cellForRow(at: indexPath) as! OptionCell
        
        if cell.checkMark.isHidden == true{
            cell.checkMark.isHidden = false
            enableNotification(index: indexPath.item)
        }else{
            cell.checkMark.isHidden = true
            disableNotification(index: indexPath.item)
        }
        
    }
    
//    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//
//
//        let cell = tableView.cellForRow(at: indexPath) as! OptionCell
//        cell.checkMark.isHidden = true
//        enableNotification(index: indexPath.item, status: false)
//
//    }
    
}

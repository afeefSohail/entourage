//
//  BlockedUserVC.swift
//  entourage
//
//  Created by afeef sohail on 11/2/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class BlockedUserVC: BaseVC {
    
    //MARK:- IBOutLets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var unblockBtn: UIButton!
    
    //MAARK: - Class Properties
    var blockedAllUser: [Friend] = []
    var selectedBlockedUsers : [Int] = []
    
    //MARK:- Constructor
    class func blockedUserVC()-> BlockedUserVC{
        let blockedUserVC = UIStoryboard(name: "ProfileViews", bundle: nil).instantiateViewController(identifier: "BlockedUserVC") as! BlockedUserVC
        
        return blockedUserVC
    }
    
    override func setupGUI() {
    }
    
    override func updateGUI() {
        title = "Blocked User"
        Utils.currVC = self
        
        getAllBlockeddUser()
    }
    
    fileprivate func getAllBlockeddUser(){
        self.startAnimation()
        WebServicesManager.shared.getBlockedFriends { (reponse, error) in
            self.stopAnimation()
            if error == nil{
                //#00c0e3
                self.selectedBlockedUsers.removeAll()
                self.unblockBtn.backgroundColor = UIColor("#D9DDE7")
                self.unblockBtn.isEnabled = false

                guard let blockedUsers = reponse as? [Friend] else{
                    return
                }
                EntourageManager.shared.setting?.block_member_count = blockedUsers.count
                self.blockedAllUser = blockedUsers
                self.tableView.reloadData()
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    fileprivate func unBlockSelectedUser(){
        self.startAnimation()
        WebServicesManager.shared.unblockedTheUsers(block_users: selectedBlockedUsers.description) { (response, error) in
            if error == nil{
                self.stopAnimation()
                EntourageManager.shared.setting?.block_member_count! -= self.selectedBlockedUsers.count
                self.navigationController?.popViewController(animated: true)
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    //MARK:- ACtions
    @IBAction func unBlockBtn(_ sender:UIButton){
        self.unBlockSelectedUser()
    }

    @IBAction func backBtn(_ sender:UIButton){
        self.navigationController?.popToRootViewController(animated: true)
    }

}

extension BlockedUserVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockedAllUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedUserVCCell", for: indexPath) as! BlockedUserVCCell
        
        cell.setUpcell(friend: blockedAllUser[indexPath.item])
        
        return cell
    }
    
}

extension BlockedUserVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! BlockedUserVCCell
        selectedBlockedUsers.append(blockedAllUser[indexPath.item].id)
        cell.checkImage.image = UIImage(named: "blockedUser")
        cell.titleLabel.textColor = UIColor("#00C0E3")
        unblockBtn.backgroundColor = selectedBlockedUsers.count > 0 ? UIColor("#00C0E3") : UIColor("#D9DDE7")
        unblockBtn.isEnabled = selectedBlockedUsers.count > 0 ? true : false
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = self.tableView.cellForRow(at: indexPath) as! BlockedUserVCCell
        cell.checkImage.image = UIImage(named: "selection_circle")
        let id = self.blockedAllUser[indexPath.item].id
        let index = self.selectedBlockedUsers.firstIndex(where: {$0 == id})!
        selectedBlockedUsers.remove(at: index)
        cell.titleLabel.textColor = .black
        unblockBtn.backgroundColor = selectedBlockedUsers.count > 0 ? UIColor("#00C0E3") : UIColor("#D9DDE7")
        unblockBtn.isEnabled = selectedBlockedUsers.count > 0 ? true : false
    }
    
}

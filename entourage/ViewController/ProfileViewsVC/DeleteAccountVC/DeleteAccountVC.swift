//
//  DeleteAccountVC.swift
//  entourage
//
//  Created by afeef sohail on 11/2/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth

class DeleteAccountVC: BaseVC {

    //MARK:- IBOutLets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var undoLbl: UILabel!

    let titleArray = ["I don’t like Entourage", "I want to try something else" , "Something is Broken" ,  "I need a break" , "I met someone" , "Other"]
    var selectedIndex = -1
    
    //MARK:- Constructor
    class func deleteAccountVC()-> DeleteAccountVC{
        let deleteAccountVC = UIStoryboard(name: "ProfileViews", bundle: nil).instantiateViewController(identifier: "DeleteAccountVC") as! DeleteAccountVC
        
        return deleteAccountVC
    }
    
    override func setupGUI() {
        title = "Delete Account"
        
        self.setUpNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!]
        
        //NavBar shadow
        //addNavBarShadow()
        self.navigationController?.navigationBar.setSettingNavBarShadow()

    }
    
    override func updateGUI() {

        title = "Delete Account"
        Utils.currVC = self
    }

    fileprivate func callDeleteAccountApi(){
        
        self.startAnimation()
        WebServicesManager.shared.deleteUserAccount(reason: titleArray[selectedIndex] ) { (reponse, error) in
            if error == nil{
                self.stopAnimation()
                Utils.appStatus = false

                EntourageManager.shared.user.removeToken()
                EntourageManager.shared.setting = nil
                EntourageManager.shared.FriendShips.removeAll()
                EntourageManager.shared.groupInviteRequestes.removeAll()
                EntourageManager.shared.groupStatuses.removeAll()
                EntourageManager.shared.groupStatuses.removeAll()
                EntourageManager.shared.otherGroups.removeAll()
                EntourageManager.shared.photos.removeAll()
                EntourageManager.shared.myMatchs.removeAll()

                Utils.resetVariables()
                
                lastMessageListner?.unsubscribe()
                
                if let id = EntourageManager.shared.myGroup?.id {
                    self.startAnimation()
                    deleteTheDocument(groupId: "\(id)", completetion: {
                        self.stopAnimation()
                        
                        resetAllUnReadMsg()
                        
                        EntourageManager.shared.myGroup = nil
                        
                        do {
                            try Auth.auth().signOut()
                        } catch {
                            print("Error signing out: \(error.localizedDescription)")
                        }

                        Utils.switchToOnBoarding()
                        
                        
                    })
                }else{
                    
                    EntourageManager.shared.myGroup = nil
                    
                    do {
                        try Auth.auth().signOut()
                    } catch {
                        print("Error signing out: \(error.localizedDescription)")
                    }

                    Utils.switchToOnBoarding()

                }
                
            }else{
                self.stopAnimation()
                self.showAlert(title: "Error", message: error!)
            }
        }

    }

    //MARK:- ACtions
    @IBAction func deleteAccountBtn(_ sender:UIButton){
        
                let vc = DeleteAccountAlertVC.deleteAccountAlertVC {
                    self.callDeleteAccountApi()
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)

        
    }
            
    @IBAction func backBtn(_ sender:UIButton){
        self.navigationController?.popToRootViewController(animated: true)
    }

}


extension DeleteAccountVC : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeleteAccountVCCell", for: indexPath) as! OptionCell
                
        cell.filterName.text = titleArray[indexPath.item]

        cell.checkMark.isHidden = selectedIndex == indexPath.item ? false : true
        
        cell.btmBreakView.isHidden = titleArray.count - 1 == indexPath.item ? false : true

        return cell
    }
    
}


extension DeleteAccountVC : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedIndex = indexPath.item
        
        deleteBtn.isHidden = false
        undoLbl.isHidden = false
        deleteBtn.backgroundColor = UIColor("#f02424")
        
        self.tableView.reloadData()
    }
}

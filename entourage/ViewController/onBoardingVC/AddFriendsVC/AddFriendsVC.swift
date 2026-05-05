//
//  AddFriendsVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import MessageUI

class AddFriendsVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var remainCounterLbl: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var searchTF: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var topView: UIView!

    
    var list : [Friend] = []
    var contacts : [String] = []
    var oldContacts : [AllContacts] = []
    var cardContacts:[AllContacts] = []
    var addMemberCounter = 0
    var follow = false
    
    var timerSeconds = 0

    override func setupGUI() {
        super.setupGUI()
        
        self.hideNavBar()
        
        topView.setBottomShadow()
        
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)
        
        self.remainCounterLbl.text = "\(addMemberCounter)/3"
        
        Utils.phoneContacts = PhoneContacts.getAllContacts()

        Utils.phoneContacts.forEach { (contact) in
            if contact.phoneNumber.count > 0{
                contacts.append(contact.phoneNumber)
            }
        }
        
        doneBtn.isEnabled = false
        doneBtn.backgroundColor = UIColor("#D2D2D2")
        
        getPhoneNumber()
        
        searchTF.searchTextField.delegate = self
        searchTF.searchTextField.backgroundColor = UIColor.clear
        searchTF.setBackgroundImage(UIImage.init(), for: UIBarPosition.any, barMetrics: UIBarMetrics.default)
        searchTF.searchTextField.font = UIFont(name: "Avenir-Medium", size: 18)
        
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissTheKeyBoard))
        upSwipeGesture.direction = .up
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissTheKeyBoard))
        downSwipeGesture.direction = .down

        tableView.addGestureRecognizer(downSwipeGesture)
        tableView.addGestureRecognizer(upSwipeGesture)
        
        setUpSubTitle()

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.timerSeconds == 6 {
                timer.invalidate()
                self.skipBtn.isHidden = false
            }else{
                self.timerSeconds += 1
            }
        }

    }
    
    fileprivate func setUpSubTitle(){
        
        let firstPart = NSMutableAttributedString(string: "Select ", attributes: [NSAttributedString.Key.foregroundColor : UIColor("#878f96") , NSAttributedString.Key.font : UIFont(name: "Avenir-Book" , size: 17)! ])
        
        let secondPart = NSMutableAttributedString(string: "add " , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#878f96") , NSAttributedString.Key.font : UIFont(name: "Avenir-Heavy" , size: 17)! ])

        let thirdPart = NSMutableAttributedString(string: "to vouch in friends to swipe with once they’re in you can " , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#878f96") , NSAttributedString.Key.font : UIFont(name: "Avenir-Book" , size: 17)! ])

        let fourthPart = NSMutableAttributedString(string: "#SwipeTogether." , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#878f96") , NSAttributedString.Key.font : UIFont(name: "Avenir-BookOblique" , size: 17)! ])

        let totalString = NSMutableAttributedString(attributedString: firstPart)
        totalString.append(secondPart)
        totalString.append(thirdPart)
        totalString.append(fourthPart)
        subTitle.attributedText = totalString
    }
    
    fileprivate func getPhoneNumber(){
        self.startAnimation()
        
        WebServicesManager.shared.getFriendsListBy(contacts: self.contacts.description,directFriendship: true) { (allFreinds, error) in
            self.stopAnimation()
            
            if error == nil{
                
                self.list = allFreinds as? [Friend] ?? []
                
                for (_,value1) in Utils.phoneContacts.enumerated(){
                    
                    var counter = 0
                    var currFrined : Friend?
                    
                    for (_,value2) in  self.list.enumerated(){
                        
                        value1.phoneNumber.forEach { (phoneNumber) in
                            
                            if value1.phoneNumber == value2.phone_number ?? ""{
                                counter += 1
                                currFrined = value2
                            }

                        }
                        
                    }
                    
                    if value1.name == " " || value1.name?.isEmpty == true  {
                        //TODO:- Nothing
                    }else if counter >= 1 , value1.phoneNumber != EntourageManager.shared.user.phone_number ?? ""{//if local phone number match from server any Phone Number

                        let cardContact = AllContacts(name: "server" , num: value1.phoneNumber, nameIntials: value1.nameIntials ?? ""  , userName: value1.name ?? "" ,avatarData: value1.avatarData,imageUrl:currFrined?.getPrimaryImageThumb() ?? "", reloationStatus: currFrined?.status ?? "")
                        
                        self.cardContacts.append(cardContact)
                        
                        if currFrined?.status ?? "" == "match"{
                            
                            self.addMemberCounter += 1
                            self.remainCounterLbl.text = "\(self.addMemberCounter)/3"

                            if self.addMemberCounter >= 3{
                                self.doneBtn.isEnabled = true
                                self.doneBtn.backgroundColor = Colors.themeColor.value
                            }

                        }

                    }else if value1.phoneNumber != EntourageManager.shared.user.phone_number ?? ""{
                        
                        let cardContact = AllContacts(name: "local", num: value1.phoneNumber , nameIntials: value1.nameIntials ?? ""  , userName: value1.name ?? ""  ,avatarData: value1.avatarData,imageUrl: "", reloationStatus: "Request" )
                        self.cardContacts.append(cardContact)
                    }
                    
                }

                self.oldContacts = self.cardContacts
                self.tableView.reloadData()
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    
    
}


// MARK: - Actions
extension AddFriendsVC {

    @objc func dismissTheKeyBoard(sender:Any){
        if searchTF.searchTextField.text?.count ?? 0 > 0{
            searchTF.searchTextField.resignFirstResponder()
        }
    }
    
    @IBAction func pressDoneBtn(_ sender: Any) {
        continueFeedBackBtn(.soft)
        if Utils.appStatus == false{
            Utils.appStatus = true
        }
        self.loadSwipeFriendsVC()
    }
   
    @IBAction func pressSkipBtn(_ sender: Any) {
        continueFeedBackBtn(.soft)
        if Utils.appStatus == false{
            Utils.appStatus = true
        }
        self.loadSwipeFriendsVC()
    }
    
    @objc func pressAddBtn(_ sender: UIButton) {

        if cardContacts[sender.tag].fullname == "local" {
            sendInviteMessage(sender: sender, index: sender.tag)
        }else if cardContacts[sender.tag].fullname == "server" {
            addFriendDirectly(sender: sender, index: sender.tag)
        }
         
    }

    
    func addFriendDirectly(sender:UIButton, index:Int){
        
        let phonumber = cardContacts[index].phoneNumber.replacingOccurrences(of: " ", with: "")
        
//        self.start_Animation()
        WebServicesManager.shared.directFriendShip(phoneNumber: phonumber) { (reponse, error) in
//            self.stop_Animation()
            
            if error == nil{
                
                guard let friend = reponse as? Friend else{
                     return
                 }
                self.cardContacts[index].reloationStatus = friend.status ?? "Request"
                self.cardContacts[index].isSelected = true
                self.tableView.reloadData()
                
                self.addMemberCounter += 1
                self.remainCounterLbl.text = "\(self.addMemberCounter)/3"

                if self.addMemberCounter >= 3{
                    self.doneBtn.isEnabled = true
                    self.doneBtn.backgroundColor = Colors.themeColor.value
                }
            
            }else{
                self.stop_Animation()
                self.showAlert(title:"Error", message: error!)
            }
        }
    }
    
    func sendInviteMessage(sender:UIButton, index:Int) {
        let phonumber = cardContacts[index].phoneNumber

  //  self.start_Animation()
        WebServicesManager.shared.sendInviteMessage(phoneNumber: phonumber) { (response, error) in
    //    self.stop_Animation()
            if error == nil{
                
                self.cardContacts[index].isSelected = true
                self.tableView.reloadData()
                
                self.addMemberCounter += 1
                self.remainCounterLbl.text = "\(self.addMemberCounter)/3"

                if self.addMemberCounter >= 3{
                    self.doneBtn.isEnabled = true
                    self.doneBtn.backgroundColor = Colors.themeColor.value
                }

            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
}

//MARK: - UITableViewDataSource , UITableViewDelegate
extension AddFriendsVC : UITableViewDataSource , UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cardContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddFriendVCCell", for: indexPath) as! AddFriendVCCell
        cell.contact = self.cardContacts[indexPath.item]
        cell.addBtn.tag = indexPath.item
        cell.addBtn.addTarget(self, action: #selector(pressAddBtn), for: .touchUpInside)
        cell.cellSetUp()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {

        if searchTF.searchTextField.text?.count ?? 0 > 0{
            searchTF.searchTextField.resignFirstResponder()
        }
    }
    
    
}

//MARK: - UITextFieldDelegate
extension AddFriendsVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

}

extension AddFriendsVC : UISearchBarDelegate{

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.searchTextField.resignFirstResponder()
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {

        searchBar.searchTextField.resignFirstResponder()
        return true
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        cardContacts = oldContacts
        cardContacts = cardContacts.filter({$0.userName.hasPrefix((searchText).capitalized) })
        tableView.reloadData()
    }
}

//
//  SearchFriendsVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/31/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit
import MessageUI

enum ListType : String {
    case All
    case Requests
    case Contacts
    case Search
}


class SearchFriendsVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var vcTitleLbl: UILabel!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var serachTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuBar: UIView!
    @IBOutlet weak var AllBtn: UIButton!
    @IBOutlet weak var RequestBtn: UIButton!
    @IBOutlet weak var contactsBtn: UIButton!
    @IBOutlet weak var menuBarBtn: UIView!
    @IBOutlet weak var menuBarLeadingMargin: NSLayoutConstraint!
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var contactsEmptyStateView: UIView!
    
    @IBOutlet weak var emptyLbl: UILabel!
    
    
    //MARK:- Class Properties
    var friendsEmptyStateText = "You need friends to start. swiping together.\nSearch for a User from the Find Friends bar above."
    var requestEmptyStateText = "You will see friend requests recieved and sent from active Users on the app."
    var menuBarWidth : CGFloat = ((UIScreen.main.bounds.width - 32) / 3)
    var callBack : importFriendsList!
    var tabType : String = "All"
    let user = EntourageManager.shared.user
    var contactCellSection = 0
    var allFriends : [Friend] = []
    var allRequests : [Friend] = []
    var allOtherContacts : [AllContacts] = []
    var phonesContacts : [AllContacts] = []
    var inviteContacts : [PhoneContact] = []
    var searchContacts : [Friend] = []
    
    var contacts : [String] = []
    var selelctedTabIndex = 0
    var follow = false
    
    
    // MARK: - Constructor
    class func loadSearchFriendsVC(flow:Bool , callback :@escaping importFriendsList )->SearchFriendsVC {
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let  searchFriendsVC = storyboard.instantiateViewController(withIdentifier: "SearchFriendsVC") as! SearchFriendsVC
        
        searchFriendsVC.callBack = callback
        searchFriendsVC.follow = flow
        
        return searchFriendsVC
    }
    
    
    override func setupGUI() {
        super.setupGUI()
        
        
        self.hideNavBar()
        
        // just to make cell height auto grow
        tableView.estimatedRowHeight = 66.0
        tableView.rowHeight = UITableView.automaticDimension
        
        
        //TO dismiss a Keybaord on more then Single text Entry
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissTheKeyBoard))
        upSwipeGesture.direction = .up
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(dismissTheKeyBoard))
        downSwipeGesture.direction = .down
        
        tableView.addGestureRecognizer(downSwipeGesture)
        tableView.addGestureRecognizer(upSwipeGesture)
        backBtn.isHidden = !follow
        doneBtn.isHidden = follow
        vcTitleLbl.text = follow == false ? "Import Friends" : "Friends List"
        
        if self.follow == false{
            self.AllBtn.isHidden = true
            self.RequestBtn.isHidden = true
            self.contactsBtn.isEnabled = false
            self.menuBarLeadingMargin.constant = (((UIScreen.main.bounds.width - 32) / 2) - ( menuBarWidth / 2))
        }
        
        menuBar.setTabViewShadow()
        
        Utils.phoneContacts = PhoneContacts.getAllContacts()
        
        getAllPhoneNumber {
            
            if self.follow == false{ // in this flow we only showing him Mobile remaining Contacts
            
                self.tabType = "Contacts"
                self.selelctedTabIndex = 3
                self.getContactsList()
            
            }else{
                
                self.setUpSelectiveTabData(tabType: self.tabType)
            
            }
        }
        
    }
    
    override func updateGUI() {
        Utils.currVC = self
        self.title = "Add Friends"
    }
    
    fileprivate func emptyStateViewSetUp(labelText:String,isShow:Bool){
        emptyLbl.text = labelText
        emptyStateView.isHidden = isShow
        contactsEmptyStateView.isHidden = true
    }
    
    fileprivate func getAllPhoneNumber(complete:@escaping ()->Void){
        
        for (index,contact) in Utils.phoneContacts.enumerated(){
            if contact.phoneNumber.count > 0{
                contacts.append(contact.phoneNumber)
            }
            
            if index == Utils.phoneContacts.count - 1{
                complete()
            }
        }
        
        
    }
    
    @objc func dismissTheKeyBoard(sender:Any){
        if serachTF.text?.count ?? 0 > 0{
            serachTF.resignFirstResponder()
        }
    }
    
    
    @objc func pressDoneBtn(){
        
        self.callBack()
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate func getAllFreindShipMembers(friendsList:[Friend],nonExistingContact:[String]){
        
        self.allFriends.removeAll()
        self.allFriends = friendsList.filter({$0.status ?? "" == "match"})
        
        if allFriends.count > 0,Utils.phoneContacts.count > 0{
            
            
            for (index) in  0..<self.allFriends.count{
                
                if let _ = Utils.phoneContacts.lastIndex(where: {$0.phoneNumber == self.allFriends[index].phone_number ?? ""}){
                    self.allFriends[index].contactType = "IN YOUR CONTACTS"
                }else{
                    self.allFriends[index].contactType = "ON APP"
                }
                
                if allFriends.count - 1 == index{
                    getInvitedMembers(nonExistingContact: nonExistingContact)
                }
                
            }
            
        }else{
            getInvitedMembers(nonExistingContact: nonExistingContact)
        }
        
        
    }
    
    fileprivate func getInvitedMembers(nonExistingContact:[String]){
        
        self.inviteContacts.removeAll()
        if nonExistingContact.count > 0,Utils.phoneContacts.count > 0{
            
            for (index,phoneNum) in nonExistingContact.enumerated(){
                
                if let index = Utils.phoneContacts.lastIndex(where: {$0.phoneNumber == phoneNum && $0.phoneNumber == EntourageManager.shared.user.phone_number ?? ""}){
                    
                    self.inviteContacts.append(Utils.phoneContacts[index])
                }
                
                if nonExistingContact.count - 1 == index{
                    tableView.reloadData()
                }
                
            }
            
        }else{
            self.tableView.reloadData()
        }
    }
    
    fileprivate func getRequestMembers(friendsList:[Friend]){
        
        self.allRequests.removeAll()
        let acceptedlist = friendsList.filter({$0.status ?? "" == "accept"})
        let requestedList = friendsList.filter({$0.status ?? "" == "requested"})
        
        self.allRequests.append(contentsOf: acceptedlist)
        self.allRequests.append(contentsOf:requestedList)
        
        if allRequests.count > 0,Utils.phoneContacts.count > 0{
            
            
            for (index) in  0..<self.allRequests.count{
                
                if let _ = Utils.phoneContacts.lastIndex(where: {$0.phoneNumber == self.allRequests[index].phone_number ?? ""}){
                    self.allRequests[index].contactType = "IN YOUR CONTACTS"
                }else{
                    self.allRequests[index].contactType = "ON APP"
                }
                
                if allRequests.count - 1 == index{
                    tableView.reloadData()
                }
                
            }
            
        }else{
            tableView.reloadData()
        }
        
    }
    
    fileprivate func getSearchMembers(friendsList:[Friend]){
        
        if searchContacts.count > 0,Utils.phoneContacts.count > 0{
            
            
            for (index) in  0..<self.searchContacts.count{
                
                if let _ = Utils.phoneContacts.lastIndex(where: {$0.phoneNumber == self.searchContacts[index].phone_number ?? ""}){
                    self.searchContacts[index].contactType = "IN YOUR CONTACTS"
                }else{
                    self.searchContacts[index].contactType = "ON APP"
                }
                
                if searchContacts.count - 1 == index{
                    tableView.reloadData()
                }
                
            }
            
        }else{
            tableView.reloadData()
        }
        
        
    }
    
}

//MARK: - Hook Apis
extension SearchFriendsVC{
    
    private func getAllListData(){
        
        self.startAnimation()
        WebServicesManager.shared.getFriendsAndInvited(contacts: self.contacts.description) { (allFreindsWithInviteNum, error) in
            self.stopAnimation()
            
            if error == nil{
                
                guard let friendsWithInvitedUser = allFreindsWithInviteNum as? FriendsWithInvitedUser else{
                    return
                }
                
                self.getAllFreindShipMembers(friendsList:friendsWithInvitedUser.friendships, nonExistingContact: friendsWithInvitedUser.nonExisting)
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    private func getRequestListData(){
        
        self.startAnimation()
        WebServicesManager.shared.getReceviedRequests() { (allRequestRecivedFreinds, error) in
            self.stopAnimation()
            
            if error == nil{
                
                let friendsList = allRequestRecivedFreinds as? [Friend] ?? []
                
                self.getRequestMembers(friendsList: friendsList)
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    fileprivate func getContactsList(){
        
        self.allOtherContacts.removeAll()//empty The list
        
        self.startAnimation()
        WebServicesManager.shared.getFriendsListBy(contacts: self.contacts.description,directFriendship: false) { (allFreinds, error) in
            self.stopAnimation()
            
            if error == nil{
                
                let friendsList = allFreinds as? [Friend] ?? []
                
                for (_,value1) in Utils.phoneContacts.enumerated(){
                    
                    var counter = 0
                    
                    for (_,value2) in  friendsList.enumerated(){
                        
                        value1.phoneNumber.forEach { (phoneNumber) in
                            if value1.phoneNumber == value2.phone_number ?? ""{ counter += 1 }
                        }
                        
                    }
                    
                    if value1.name == " " || value1.name?.isEmpty == true  {
                        //TODO:- Nothing
                    }else if counter >= 1 , value1.phoneNumber != EntourageManager.shared.user.phone_number ?? ""{//if local phone number match from server any Phone Number
                        
                    }else if value1.phoneNumber != EntourageManager.shared.user.phone_number ?? ""{
                        
                        let cardContact = AllContacts(name: "local", num: value1.phoneNumber , nameIntials: value1.nameIntials ?? ""  , userName: value1.name ?? ""  ,avatarData: value1.avatarData,imageUrl: "", reloationStatus: "Request" )
                        self.allOtherContacts.append(cardContact)
                        
                    }
                    
                }
                
                self.phonesContacts = self.allOtherContacts
                self.tableView.reloadData()
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    
    func contactsPermissionAlert(){
        
        contactsPermission { (granted, error) in
            if granted {
                
                DispatchQueue.main.async {
                    self.emptyStateView.isHidden = false
                    self.contactsEmptyStateView.isHidden = false
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.emptyStateView.isHidden = true
                }
            }
            
        }
        
    }
}

// MARK: - Action
extension SearchFriendsVC {
    
    private func setUpSelectiveTabData(tabType:String){
        
        serachTF.placeholder = tabType == ListType.Contacts.rawValue ? "Search by Name" : "Search by Username"
        self.tabType = tabType

        switch tabType {
        case ListType.All.rawValue:
            
            selelctedTabIndex = 1
            menuBarLeadingMargin.constant = CGFloat(menuBarWidth * 0)
            setUpSelectiveTabBtn(tab:selelctedTabIndex,btn1: AllBtn,btn2:RequestBtn,btn3:contactsBtn)
            getAllListData()
            break
        case ListType.Requests.rawValue:
            selelctedTabIndex = 2
            menuBarLeadingMargin.constant = CGFloat(menuBarWidth * 1)
            setUpSelectiveTabBtn(tab:selelctedTabIndex,btn1: AllBtn,btn2:RequestBtn,btn3:contactsBtn)
            getRequestListData()
            break
        case ListType.Contacts.rawValue:
            selelctedTabIndex = 3
            menuBarLeadingMargin.constant = CGFloat(menuBarWidth * 2)
            setUpSelectiveTabBtn(tab:selelctedTabIndex,btn1: AllBtn,btn2:RequestBtn,btn3:contactsBtn)
            getContactsList()
            break
        default:
            break
        }
    }
    
    @IBAction func pressAllBtn(sender:UIButton){
        setUpSelectiveTabData(tabType: "All")
    }
    
    @IBAction func pressRequestBtn(sender:UIButton){
        setUpSelectiveTabData(tabType: "Requests")
    }
    
    @IBAction func pressContactsBtn(sender:UIButton){
        emptyStateView.isHidden = true
        setUpSelectiveTabData(tabType: "Contacts")
    }
    
    @IBAction func SearchFieldValueChanged(_ sender:UITextField){
        
        if tabType == ListType.Contacts.rawValue  , sender.text ?? "" != ""{// if we are searching on mobile contacts list
            
            let serachText = (sender.text!).lowercased()
            allOtherContacts = phonesContacts.filter( { $0.userName.lowercased().contains(serachText) } )
            self.tableView.reloadData()
            
        }else if tabType == ListType.Contacts.rawValue ,  sender.text ?? "" == ""{
            
            allOtherContacts = phonesContacts
            self.tableView.reloadData()

        }else if sender.text ?? "" != "" ,  follow  != false{
            
            emptyStateView.isHidden = true
            
            tabType = "Search"
            WebServicesManager.shared.searchBy(userName: sender.text!) { (response, error) in
                
                if error == nil{
                    
                    guard let friendShipList = response as? [Friend] else{
                        return
                    }
                    
                    self.searchContacts = friendShipList
                    self.getSearchMembers(friendsList: self.searchContacts)
                    
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }
            
        }else if   follow  != false{
            
            if selelctedTabIndex == 1{
                tabType = "All"
                setUpSelectiveTabData(tabType: tabType)
            }else if selelctedTabIndex == 2{
                tabType = "Requests"
                setUpSelectiveTabData(tabType: tabType)
            }else if selelctedTabIndex == 3{
                tabType = "Contacts"
                setUpSelectiveTabData(tabType: tabType)
            }
            
        }
        
    }
}


//MARK: - UITableViewDataSource
extension SearchFriendsVC : UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        var numberOfSection = 0
        
        if tabType == ListType.All.rawValue{
            
            emptyStateViewSetUp(labelText: friendsEmptyStateText, isShow: allFriends.count > 0 ? true : false)// when friends count is ZERO then show emptyState
            
            if allFriends.count > 0{
                tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 0)
                numberOfSection += 1
                
                if inviteContacts.count > 0 {
                    tableView.contentInset = UIEdgeInsets(top: 14, left: 0, bottom: 0, right: 0)
                    numberOfSection += 1
                }
            }
            
            
        }else if tabType == ListType.Requests.rawValue{
            
            emptyStateViewSetUp(labelText: requestEmptyStateText, isShow: allRequests.count > 0 ? true : false)// when friends count is ZERO then show emptyState
            
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return allRequests.count > 0 ? 1 : 0
        }else if tabType == ListType.Contacts.rawValue{
            
            emptyStateViewSetUp(labelText: requestEmptyStateText, isShow: true)// when friends count is ZERO then show emptyState
            
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return allOtherContacts.count > 0 ? 1 : 0
        }else if tabType == ListType.Search.rawValue{
            
            emptyStateViewSetUp(labelText: requestEmptyStateText, isShow: true)// when friends count is ZERO then show emptyState
            
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            return searchContacts.count > 0 ? 1 : 0
        }
        
        return numberOfSection
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        
        if tabType == ListType.All.rawValue{
            
            if allFriends.count > 0 , section == 0{
                
                let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20) )
                view.headerTitleLabel.text = "Friends on Entourage"
                return view
                
            }else if inviteContacts.count > 0,allFriends.count > 0{
                
                let view = SectionHeaderView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 20) )
                view.headerTitleLabel.text =  "Invite Friends"
                
                return view
                
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tabType == ListType.All.rawValue{
            if allFriends.count > 0 , section == 0{
                return 40
            }else if inviteContacts.count > 0,allFriends.count > 0{
                return 40
            }
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tabType == ListType.All.rawValue{
            
            if allFriends.count > 0 , section == 0{
                return allFriends.count
            }else if inviteContacts.count > 0,allFriends.count > 0{
                return inviteContacts.count
            }
            
        }else if tabType == ListType.Requests.rawValue{
            return allRequests.count
        }else if tabType == ListType.Contacts.rawValue{
            return allOtherContacts.count
        }else{
            return searchContacts.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        if tabType == ListType.All.rawValue{
            
            if allFriends.count > 0 , indexPath.section == 0, allFriends.indices.contains(indexPath.item){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "EntouragsContractCell", for: indexPath) as! EntouragsContractCell
                
                cell.friend = self.allFriends[indexPath.item]
                cell.friendCell(vc: self, section: indexPath.section )
                cell.cellBtn.tag = indexPath.row
                
                
                return cell
                
            }else if inviteContacts.count > 0,allFriends.count > 0 , inviteContacts.indices.contains(indexPath.item){
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "InviteFriendsCell", for: indexPath) as! InviteFriendsCell
                
                cell.contact = self.inviteContacts[indexPath.item]
                cell.cellSetUp()
                contactCellSection = indexPath.section
                cell.cellBtn.tag = indexPath.item
                cell.cellBtn.addTarget(self, action: #selector(pressInviteBtn), for:    .touchUpInside)
                
                if cell.contact.isSelected == true{
                    cell.cellBtn.isEnabled = false
                    cell.cellBtn.setTitle("Invited", for: .normal)
                    cell.cellBtn.layer.borderWidth = 0
                    cell.cellBtn.setTitleColor(UIColor.white, for: .normal)
                    cell.cellBtn.backgroundColor = UIColor("#D2D2D2")
                }else{
                    cell.cellBtn.isEnabled = true
                    cell.cellBtn.setTitle("Invite", for: .normal)
                    cell.cellBtn.layer.borderWidth = 2
                    cell.cellBtn.setTitleColor(Colors.themeColor.value, for: .normal)
                    cell.cellBtn.backgroundColor = UIColor.white
                }
                
                return cell
                
            }
            
        }else if tabType == ListType.Requests.rawValue,allRequests.indices.contains(indexPath.item){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EntouragsContractCell", for: indexPath) as! EntouragsContractCell
            
            cell.friend = self.allRequests[indexPath.item]
            cell.requestCell(vc: self, section: indexPath.section )
            cell.cellBtn.tag = indexPath.row
            
            return cell
            
        }else if tabType == ListType.Contacts.rawValue, allOtherContacts.indices.contains(indexPath.item){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "PhoneContacts", for: indexPath) as!  AddFriendVCCell
            contactCellSection = indexPath.section
            cell.contact = self.allOtherContacts[indexPath.item]
            cell.addBtn.tag = indexPath.row
            cell.addBtn.addTarget(self, action: #selector(pressInviteBtn), for: .touchUpInside)
            cell.cellSetUp()
            
            return cell
            
        }else if tabType == ListType.Search.rawValue, searchContacts.indices.contains(indexPath.item){
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "EntouragsContractCell", for: indexPath) as! EntouragsContractCell
            
            cell.friend = self.searchContacts[indexPath.item]
            cell.cellSetUp(vc: self, section: indexPath.section )
            cell.cellBtn.tag = indexPath.row
            
            return cell
            
        }
        
        return UITableViewCell()
        
    }
    
    
    @objc func pressInviteBtn(sender:UIButton){
        
        var phoneNumber : String = ""
        
        if tabType == ListType.Contacts.rawValue{
            
            phoneNumber = self.allOtherContacts[sender.tag].phoneNumber
            self.allOtherContacts[sender.tag].isSelected = true
            
        }else if tabType == ListType.All.rawValue{
            
            phoneNumber = self.inviteContacts[sender.tag].phoneNumber
            self.inviteContacts[sender.tag].isSelected = true
            
        }
        
        self.tableView.reloadSections([contactCellSection], with: .none)
        self.sendInviteMessage(phoneNumber: phoneNumber)
    }
    
    
    fileprivate func sendInviteMessage(phoneNumber:String) {
        
        self.startAnimation()
        WebServicesManager.shared.sendInviteMessage(phoneNumber: phoneNumber) { (response, error) in
            self.stopAnimation()
            
            if error == nil{
        
                print(response as! String)
            
            }else{ self.showAlert(title: "Error", message: error!) }
        
        }
    
    }
    
    
    
    
}

//MARK: - UITableViewDelegate
extension SearchFriendsVC: UITableViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if serachTF.text?.count ?? 0 > 0 { serachTF.resignFirstResponder() }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
    
}

// MARK: - SwipeTableViewCellDelegate
extension SearchFriendsVC{
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if tabType == ListType.Contacts.rawValue { return nil }
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "Block", handler: { (action,view,completionHandler ) in
            
            var id = 0
            
            if self.tabType == ListType.All.rawValue{
                
                if self.allFriends.count > 0 , indexPath.section == 0{ id = self.allFriends[indexPath.item].id}
                
            }else if self.tabType == ListType.Requests.rawValue{ id = self.allRequests[indexPath.item].id }
            
            else{ id = self.searchContacts[indexPath.item].id }
            
            self.startAnimation()
            WebServicesManager.shared.blockFriend(frendId: id) { (reponse, error) in
                self.stopAnimation()
                if error == nil{
                    
                    if reponse != nil{
                        
                        EntourageManager.shared.setting?.block_member_count! += 1
                        
                        if self.tabType == ListType.All.rawValue{
                            
                            if self.allFriends.count > 0 , indexPath.section == 0{
                                
                                if let index = self.allFriends.lastIndex(where: {$0.id == id}) {
                                    self.allFriends.remove(at: index)
                                }
                                
                            }
                            
                        }else if self.tabType == ListType.Requests.rawValue{
                            
                            if let index = self.allRequests.lastIndex(where: {$0.id == id}) { self.allRequests.remove(at: index) }
                            
                        }else{
                            
                            if let index = self.searchContacts.lastIndex(where: {$0.id == id}) { self.searchContacts.remove(at: index) }
                        }
                        
                        tableView.reloadData()
                        
                    }else{
                        
                        self.showAlert(title: "Error", message: error!)
                        
                    }
                }
            }
            
        })
        
        // customize  Deletion the action appearance
        deleteAction.backgroundColor = UIColor("#f02424")
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
        
    }
    
}


// MARK: - UITextFieldDelegate
extension SearchFriendsVC : UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}



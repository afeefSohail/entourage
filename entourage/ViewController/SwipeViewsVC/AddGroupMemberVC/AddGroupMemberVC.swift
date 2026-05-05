//
//  AddGroupMemberVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/1/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit


class AddGroupMemberVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var PressContinueBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var tab1View: UIView!
    @IBOutlet weak var tab1ContainerView: UIView!

    @IBOutlet weak var tab2View: UIView!
    
    @IBOutlet weak var tab1Lbl: UILabel!
    @IBOutlet weak var tab2Lbl: UILabel!
    
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var contniueBtnOuterView: UIView!
    @IBOutlet weak var continueBtnOuterViewHeight: NSLayoutConstraint!
    @IBOutlet weak var searchTF : UITextField!
    
    //Empty List View
    @IBOutlet weak var emptyListView: UIView!
    @IBOutlet weak var emptyListLbl: UILabel!

    @IBOutlet weak var userPhoto1Width: NSLayoutConstraint!
    @IBOutlet weak var userPhoto2Width: NSLayoutConstraint!
    @IBOutlet weak var userPhoto3Width: NSLayoutConstraint!
    @IBOutlet weak var userPhoto1Leading: NSLayoutConstraint!
    @IBOutlet weak var userPhoto2Leading: NSLayoutConstraint!

    
    //MARK:- Class Properties
    var callback : friendIds!
    var user = EntourageManager.shared.user
    var myGroup = EntourageManager.shared.myGroup
    
    var searchFriendList : [User] = []
    var combineFriendList:  [User] = []
    var friendList = EntourageManager.shared.FriendShips.compactMap({User.userFriend(user: $0)})
    var groupMember : [User] = []
    var tab1FriendIds : [Int] = []
    var tab2FriendIds : [Int] = []
    var friendIds : [Int] = []
    var currSelectionCounter = 0
    var maxSelectionCounter = 3
    
    
    override func setupGUI() {
        super.setupGUI()
        
        self.title = "addMember"
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        tableView.tableFooterView = UIView()
        
        self.contniueBtnOuterView.setViewShadow()
        
        self.sheetViewController?.handleScrollView(self.tableView) 
     
        let lblText = "Your recent friends will appear here,\n select Import Friends to create a group."
        emptyListLbl.createTapLabl(text:lblText  , inRange: NSRange(location:46 , length: 14))
        
    }
    
    override func updateGUI() {
        
        createCombineUserList {
            
            self.tab1ContainerView.isHidden = RecentUsers.getSavedRecentUsers()?.isEmpty ?? true
            
            if self.tab1ContainerView.isHidden {
                self.setTabView(activeTab: 1)
            }else{
                self.setTabView(activeTab: 0)
            }
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //self.animation()
    }
    
    fileprivate func createCombineUserList(complete:@escaping ()->Void){
        
        
        friendIds = []
        groupMember = myGroup?.allGroupMember().filter({$0.id != user.id}) ?? []//remove me from friendList
        groupMember.forEach({friendIds.append($0.id) })

        if friendIds.count >= 1 , friendIds.count <= 3{
            self.PressContinueBtn.isEnabled = true
            self.changeContinueBtnColor()
        }else{
            self.PressContinueBtn.isEnabled = false
            self.changeContinueBtnColor()
        }

        friendList = EntourageManager.shared.FriendShips.compactMap({User.userFriend(user: $0)})
        friendList = friendList.filter({$0.id != user.id})//remove me from friendList
        
        groupMember.forEach { (invitedUser) in
            if friendList.contains(where: {$0.id == invitedUser.id}) == false{
                friendList.append(invitedUser)
            }
        }

        RecentUsers.getSavedRecentUsers()?.forEach { (user) in
            if friendList.contains(where: {$0.id == user.id}) == false{
                friendList.append(user)
            }
        }
        
        combineFriendList = friendList
        friendList = []
        complete()
    }
    
    fileprivate func currentGroup(){
        
        var images : [String] = []
        
        maxSelectionCounter = 3
        
        let selectedMember = self.combineFriendList.filter({self.friendIds.contains($0.id)})
        selectedMember.forEach({images.append($0.getPrimaryImageThumb())})
        
        
        currSelectionCounter = friendIds.count
        errorLabel.text = "\(friendIds.count)/3"

        userPhoto1Width.constant = 40
        userPhoto2Width.constant = 40
        userPhoto3Width.constant = 40
        userPhoto1Leading.constant = -16
        userPhoto2Leading.constant = -16

        print(friendIds.count)
        
        for index in 1...3{
            
            let image = getImageViewWith(tag: 8-index , view: self.view)
            let imageView = getViewWith(tag: 4-index, view: self.view)
            
            image.isHidden =  false
            imageView.layer.borderColor = UIColor.white.cgColor
            
            if index <= friendIds.count{
                
                if let url = URL(string:images[index-1]){
                    image.kf.indicatorType = .activity
                    //image.kf.setImage(with: url)
                    setupThumnail(url: url, IV: image)
                }
                
            }else{
                
                //no Member added in your group Member
                if friendIds.count == 0{
                    
                    if index != 1{//only last image show if no group Created.
                        image.image = UIImage(named: "Group 4")
                        image.isHidden = true
                        imageView.layer.borderColor = UIColor.clear.cgColor
                    }else{
                        image.image = UIImage(named: "Group 4")
                    }
                    
                }else {
                    
                    image.isHidden = true
                    imageView.layer.borderColor = UIColor.clear.cgColor
                }
            }
        }
        
    }
    
    fileprivate func createGroup(index:Int,friendIds:[Int],groupId:Int){
        
        if index >= friendIds.count{
            self.stopAnimation()
            Utils.updateMyGroup = true
            self.closeAnimation()
            return
        }
        
        self.startAnimation()
        WebServicesManager.shared.addMember(groupId: groupId , friendsId: friendIds[index]) { (response, error) in
            if error == nil{
                self.createGroup(index: index+1, friendIds: friendIds  , groupId: groupId )
            }else{
                self.stopAnimation()
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    
    
    
    fileprivate func closeAnimation(){
        
        self.dismiss(animated: true) {
            
            if self.myGroup == nil{ // add members in New Group
                self.callback(self.friendIds)
            }else{ // adding new members in active/inactive Group
                self.callback([])
            }
        }
        
    }

    
    fileprivate func animation(){
        
        //self.containerViewHeight.constant = self.view.frame.height - 230
        self.continueBtnOuterViewHeight.constant = 88
        
        
        self.PressContinueBtn.isHidden = true
        
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
            
        }) {(bool) in
            self.PressContinueBtn.isHidden = false
        }
    }
    
    fileprivate func changeContinueBtnColor(){
        self.PressContinueBtn.backgroundColor = self.PressContinueBtn.isEnabled == false ? UIColor("#D2D2D2") : Colors.themeColor.value
    }
    
    fileprivate func setTabView(activeTab:Int){
        if activeTab == 0{
            tab1Lbl.textColor = UIColor.black
            tab1Lbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
            tab2Lbl.textColor = UIColor.lightGray
            tab2Lbl.font = UIFont(name: "Avenir-Book", size: 17)
            tab1View.isHidden = false
            tab2View.isHidden = true
            tab1ReloadView()
        }else{
            tab2Lbl.textColor = UIColor.black
            tab2Lbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
            tab1Lbl.textColor = UIColor.lightGray
            tab1Lbl.font = UIFont(name: "Avenir-Book", size: 17)
            tab2View.isHidden = false
            tab1View.isHidden = true
            tab2ReloadView()
        }
    }
    
    fileprivate func tab1ReloadView(){
        
        friendList = []
        friendList = RecentUsers.getSavedRecentUsers() ?? []
        
        searchFriendList = friendList
        
        if friendList.count == 0 , EntourageManager.shared.FriendShips.count == 0{
            self.emptyListView.isHidden = false
        }else{
            self.emptyListView.isHidden = true
        }
        
        currentGroup()

        searchTF.text = ""
        tableView.reloadData()
    }
    
    fileprivate func tab2ReloadView(){
                
        friendList = []
        friendList = EntourageManager.shared.getFriensOnly(allGroupMembers: groupMember)
        friendList.append(contentsOf: groupMember.reversed())

        friendList = friendList.filter({$0.id != user.id}).reversed()
        searchFriendList = friendList
        currentGroup()

        if friendList.count == 0{
            self.emptyListView.isHidden = false
        }else{
            self.emptyListView.isHidden = true
        }
        
        
        searchTF.text = ""
        tableView.reloadData()

    }
    
    fileprivate func searchValue(text:String){
        
        searchFriendList = friendList.filter({$0.surname().hasPrefix((text).capitalized) })
        
        tableView.reloadData()
    }
    
}
// MARK: - Actions
extension AddGroupMemberVC{
    
    @IBAction func SearchFieldValueChanged(_ sender:UITextField){
        searchValue(text: sender.text ?? "")
    }

    @IBAction func PressImportLinkBtn(_ sender: Any) {
    
        self.dismiss(animated: false) {
            self.callback([-1])
        }

    }
    
    @IBAction func PressContinueBtn(_ sender: Any) {
        notificationFeedBackBtn(.success)
        if myGroup?.users.count ?? 0 > 0 || myGroup?.invitedUsers?.count ?? 0 > 0{
            
            var ids = self.myGroup?.users.compactMap({$0.id}) ?? []
            let invitedId = self.myGroup?.invitedUsers?.compactMap({$0.id}) ?? []
            
            ids.append(contentsOf: invitedId)
            
            
            let newFriendIds = self.friendIds.filter({!ids.contains($0)})
            
            createGroup(index: 0 , friendIds: newFriendIds  , groupId: myGroup!.id)
            
            
        }else{
            
            closeAnimation()
        }
        
        
        
    }

    @IBAction func pressRecentBtn(sender:UIButton){
        setTabView(activeTab: 0)
    }
    
    @IBAction func pressAllFriendBtn(sender:UIButton){
        setTabView(activeTab: 1)
    }
    
    @objc func invitedBtnPressed(sender:UIButton){
        
        let vc = CancelInviteVC.cancelInviteVC(friendId: searchFriendList[sender.tag].id) {
            
            self.myGroup?.invitedUsers?.removeAll(where: {$0.id == self.searchFriendList[sender.tag].id})
            self.updateGUI()
            self.callback([-2])

        }
        
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)

    }
    
    
}

// MARK: - AddGroupMemberVC
extension AddGroupMemberVC{
    
    class func loadAddGroupMemberVC(callback:@escaping friendIds)->AddGroupMemberVC{
        
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let  addGroupMemberVC = storyboard.instantiateViewController(withIdentifier: "AddGroupMemberVC") as! AddGroupMemberVC
        
        addGroupMemberVC.callback = callback
        
        return addGroupMemberVC
    }
}

//MARK: - UITableViewDataSource
extension AddGroupMemberVC : UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchFriendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddGroupMemberVCCell", for: indexPath) as! AddGroupMemberVCCell
        
        
        if friendIds.contains(searchFriendList[indexPath.item].id ){
            
            
            if myGroup?.users.contains(where: {$0.id == searchFriendList[indexPath.item].id }) ?? false{
                searchFriendList[indexPath.item].isMember = true
                cell.setUpcell(friend: searchFriendList[indexPath.item] , inviteAccepted: "Yes" )
            }else if myGroup?.invitedUsers?.contains(where: {$0.id == searchFriendList[indexPath.item].id }) ?? false{
                searchFriendList[indexPath.item].isMember = false
                cell.invitedBtn.tag = indexPath.item
                cell.invitedBtn.addTarget(self, action: #selector(invitedBtnPressed), for: .touchUpInside)
                cell.setUpcell(friend: searchFriendList[indexPath.item] , inviteAccepted: "No")
            }else{
                searchFriendList[indexPath.item].isMember = false
                cell.setUpcell(friend: searchFriendList[indexPath.item] , inviteAccepted: "Selected")
            }
            
            self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            
        }else{
            cell.invitedBtn.isEnabled = false
            searchFriendList[indexPath.item].isMember = false
            cell.setUpcell(friend: searchFriendList[indexPath.item] , inviteAccepted: "Nothing" )
        }
        
        
        return cell
        
    }
    
    
}

//MARK: - UITableViewDelegate
extension AddGroupMemberVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let cell = self.tableView.cellForRow(at: indexPath) as! AddGroupMemberVCCell
        
        if currSelectionCounter < maxSelectionCounter{
            
            if friendIds.contains(searchFriendList[indexPath.item].id ) == false{
                friendIds.append(searchFriendList[indexPath.item].id)
            }
            
            self.currentGroup()
            
            cell.checkImage.image = currSelectionCounter >= maxSelectionCounter+1 ? UIImage(named: "group") : UIImage(named: "activotyGroup")
            cell.titleLabel.textColor = currSelectionCounter >= maxSelectionCounter+1 ? UIColor.black : UIColor(named: "themeColor")
            
            if currSelectionCounter >= 1 , currSelectionCounter <= maxSelectionCounter{
                self.PressContinueBtn.isEnabled = true
                self.changeContinueBtnColor()
            }else{
                self.PressContinueBtn.isEnabled = false
                self.changeContinueBtnColor()
            }
                                    
        }else{
            errorLabel.shake()
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        
        if myGroup?.users.contains(where: {$0.id == searchFriendList[indexPath.item].id }) ?? false || myGroup?.invitedUsers?.contains(where: {$0.id == searchFriendList[indexPath.item].id }) ?? false{
            
            self.tableView.reloadRows(at: [indexPath], with: .none)
            
        }else{
            
            let cell = self.tableView.cellForRow(at: indexPath) as! AddGroupMemberVCCell
            
            cell.checkImage.image = UIImage(named: "selection_circle")
            cell.titleLabel.textColor = UIColor.black
            
            if currSelectionCounter >= 1{
                
                let id = self.searchFriendList[indexPath.item].id
                let index = self.friendIds.firstIndex(where: {$0 == id})!
                
                friendIds.remove(at: index)
                currentGroup()
            }
            
            if currSelectionCounter >= 1 , currSelectionCounter <= maxSelectionCounter{
                self.PressContinueBtn.isEnabled = true
                self.changeContinueBtnColor()
            }else{
                self.PressContinueBtn.isEnabled = false
                self.changeContinueBtnColor()
            }
                        
            
        }
        
    }
    
}

// MARK: - UITextFieldDelegate
extension AddGroupMemberVC : UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

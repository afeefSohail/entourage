//
//  ActiveProfileVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/15/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Kingfisher
import FittedSheets

class ActiveProfileVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var whiteMaskHeight: NSLayoutConstraint!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var groupStatusBtnImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var groupStatus: UILabel!
    

    @IBOutlet weak var groupActivityNameLabel: UILabel!
    @IBOutlet weak var groupStatusDesc: UILabel!
    @IBOutlet weak var groupEventView: UIView!
    @IBOutlet weak var groupStatusImage: UIImageView!
    @IBOutlet weak var groupStatusBG: UIView!
    @IBOutlet weak var groupStatusEditBtn: UIButton!
    @IBOutlet weak var groupStatusEditImage: UIImageView!

    @IBOutlet weak var firstInviteNameLabel: UILabel!
    @IBOutlet weak var firstInvitedIcon: UIImageView!
    @IBOutlet weak var firstInviteMemberBtn: UIButton!
    
    @IBOutlet weak var secInviteNameLabel: UILabel!
    @IBOutlet weak var secInviteMemberBtn: UIButton!
    @IBOutlet weak var secondInvitedIcon: UIImageView!
    
    
    @IBOutlet weak var thiredInviteNameLabel: UILabel!
    @IBOutlet weak var thiredInviteMemberBtn: UIButton!
    @IBOutlet weak var thiredInvitedIcon: UIImageView!
    
    @IBOutlet weak var activeFriendsBtn: UIButton!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var shareUserView: UIView!

    //    @IBOutlet weak var premiumView: UIView!
    //    @IBOutlet weak var groupLikedCardView: UIView!
    //    @IBOutlet weak var emptyView: UIView!
    //
    //    @IBOutlet weak var pageController: UIPageControl!
    //    @IBOutlet weak var premiumCollectionView: UICollectionView!
    //    @IBOutlet weak var groupCollectionView: UICollectionView!
    
    @IBOutlet weak var topViewheight : NSLayoutConstraint!
    
    
    @IBOutlet weak var importBtn: UIButton!
    
    
    
    //MARK:- Class Properties
    let premiumTextArray = ["No more waiting, Unlimited Likes" , "Match with Groups that have already Liked",
                            "Additional Filter Settings to Narrow Groups","Create your own Custom Group Status",
                            "5x Additional Instant Matches"]
    let premiumImageArray = ["heart","GroupLiked","GroupFilter","GroupStatus","InstantMatching"]
    let numImages = 5
    var pageIndex = 0
    
    var user = EntourageManager.shared.user
    var myGroup = EntourageManager.shared.myGroup
    var friends : [Friend] = []
    var groupMember : [User] = []
    var friendIds : [Int] = []
    var callback : PressOkay!
    
    override func setupGUI() {
        super.setupGUI()
                
        topViewheight.constant = 30 + Constants.statusBarHeight
    
    }
    
    override func updateGUI(){
        
        title = "Active Profile"
        Utils.currVC = self
        updateView()
        
    }
    
    fileprivate func updateView(){
        
        user = EntourageManager.shared.user
        myGroup = EntourageManager.shared.myGroup
        self.friends = EntourageManager.shared.FriendShips
        
        if let url = URL(string: user.getPrimaryImageMedium()) {
            profileImage.kf.indicatorType = .activity
            //profileImage.kf.setImage(with: url)
            setupThumnail(url: url, IV: profileImage)
        }
        
        getFriends()
        setUpView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        pageController.customPageControlNewDesgin(dotFillColor: UIColor("#D2D2D2"), dotBorderColor: UIColor("#6C62FF"), dotBorderWidth: 2)
    }
    
    private func addLongPressGesture(Btn:UIButton, BtnAction:Selector){
        
        let longPress = UILongPressGestureRecognizer(target: self, action: BtnAction )
        longPress.minimumPressDuration = 1.5

        let tapPress = UITapGestureRecognizer(target: self, action: BtnAction)
        
        
        Btn.addGestureRecognizer(longPress)
    }
    
    fileprivate func setUpView(){
        
        
        var images : [String] = []
        
        let name = NSMutableAttributedString(string: "\(user.first_name ?? ""),", attributes: [NSAttributedString.Key.foregroundColor : UIColor("#313334") , NSAttributedString.Key.font : UIFont(name: "Avenir-Book" , size: 28)! ])
        
        let age = NSMutableAttributedString(string: " \(user.age ?? 0)" , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#313334") , NSAttributedString.Key.font : UIFont(name: "Avenir-Book" , size: 28)! ])
        
        let nameWithAge = NSMutableAttributedString(attributedString: name)
        nameWithAge.append(age)
        
        userNameLabel.attributedText = nameWithAge
        nameLbl.text = self.user.user_name ?? ""
        nameLbl.textColor = Colors.themeColor.value
        activeFriendsBtn.setTitle( "Friends (\(self.friends.count))", for: .normal)

        if myGroup?.status == "active"{
            
            shareUserView.isHidden = self.friends.count > 0 ? false : true
            groupEventView.isHidden = false
            whiteMaskHeight.constant = self.friends.count > 0 ? 495 : 430
            
            guard let url = URL(string: myGroup?.groupStatus.icon ?? "") else{
                return
            }
            
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
                switch result {
                case .success(let value):
                    
                    self.groupStatusImage.image = value.image
                    self.groupActivityNameLabel.text = self.myGroup?.groupStatus.name ?? ""
                    self.groupActivityNameLabel.font = UIFont(name: "Avenir-Medium" , size: 16.0)!
                    self.groupActivityNameLabel.textColor = self.myGroup?.groupStatus.statusType == "place" ? UIColor("#6c62ff") : UIColor.black
                    
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            
            shareUserView.isHidden = self.friends.count > 0 ? false : true
            whiteMaskHeight.constant = self.friends.count > 0 ? 495 : 430

            groupStatusBG.backgroundColor = UIColor("#F6F7FA")
            groupStatusEditBtn.isHidden = false
            groupStatusEditImage.isHidden = false
            groupStatus.text = "Active Group"
            
            if myGroup?.users.count == 4{
                groupStatusDesc.text = "See what your group is talking about…"
                groupStatusBtnImage.image = UIImage(named: "bttnGroupChat")!
            }else{
                groupStatusDesc.text = "Invite more friends to join your group."
                groupStatusBtnImage.image = UIImage(named: "bttInviteFriends")!
            }
            
            importBtn.setTitle("Leave Group", for: .normal)
            
        }else if myGroup == nil || myGroup?.status == "inactive" , friends.count == 0 {
            
            shareUserView.isHidden = true
            whiteMaskHeight.constant = 430

            self.groupStatusImage.image = UIImage(named: "share")
            self.groupActivityNameLabel.text = self.user.user_name ?? ""
            self.groupActivityNameLabel.font = UIFont(name: "Avenir-BlackOblique" , size: 18.0)!
            self.groupActivityNameLabel.textColor = UIColor("#d2d2d2")

            groupStatusBG.backgroundColor = UIColor.clear
            groupStatusEditBtn.isHidden = true
            groupStatusEditImage.isHidden = true
            groupEventView.isHidden = false
            groupStatus.text = "InActive Group"
            groupStatusBtnImage.image = UIImage(named: "InviteFriendsbtn")!
            groupStatusDesc.text = "Import friends to create a group."

            importBtn.setTitle("Share", for: .normal)
            
        }else if myGroup == nil || myGroup?.status == "inactive" {
                        
            shareUserView.isHidden = false
            groupEventView.isHidden = true
            whiteMaskHeight.constant = 430
                        
            groupStatus.text = "InActive Group"
            groupStatusBtnImage.image = UIImage(named: "bttnCreateGroup")!
            groupStatusDesc.text = "Import friends to create a group."
            
            importBtn.setTitle("Import Friends", for: .normal)
        }
        
        
        groupMember = myGroup?.allGroupMember().filter({$0.id != user.id}) ?? []
        
        groupMember.forEach({images.append($0.getPrimaryImageMedium())})
        
        
        for (index) in 0...2{
            
            let image = getImageViewWith(tag: index+1 , view: self.view)
            let view = getViewWith(tag: index+4, view: self.view)
            image.contentMode = .scaleAspectFill
            
            
            if index+1 <= groupMember.count{
                
                if let url = URL(string:images[index]){
                    image.kf.indicatorType = .activity
                    //image.kf.setImage(with: url)
                    setupThumnail(url: url, IV: image)
                }
                
                
                if groupMember.indices.contains(0) , index == 0{
                    firstInvitedIcon.isHidden = true
                    self.setUpGroupMemberView(index: 0, View:view , label: firstInviteNameLabel)
                }else if groupMember.indices.contains(1), index == 1{
                    secondInvitedIcon.isHidden = true
                    self.setUpGroupMemberView(index: 1, View:view , label: secInviteNameLabel)
                }else if groupMember.indices.contains(2), index == 2{
                    thiredInvitedIcon.isHidden = true
                    self.setUpGroupMemberView(index: 2, View:view , label: thiredInviteNameLabel)
                }
                
            }else{
                
                image.image = UIImage(named: "addGroup")!
                view.alpha = 0
                
                if index == 0{
                    firstInvitedIcon.isHidden = true
                    setEmptyView(index: 0,label: firstInviteNameLabel)
                }else if index == 1{
                    secondInvitedIcon.isHidden = true
                    setEmptyView(index: 1,label: secInviteNameLabel)
                }else if index == 2{
                    thiredInvitedIcon.isHidden = true
                    setEmptyView(index: 2,label: thiredInviteNameLabel)
                }
                
            }
            
        }
    }
    
    fileprivate func setUpGroupMemberView(index:Int,View:UIView,label:UILabel){
        if groupMember[index].isMember == true{//Group Member
            
            label.text = groupMember[index].first_name ?? ""
            label.font = UIFont(name: "Avenir-BlackOblique" , size: 14)
            label.textColor = UIColor("#313334")
            View.alpha = 0
            
        }else if groupMember[index].isMember == false{//Invited Member
            
            if index == 0{
                firstInvitedIcon.isHidden = false
            }else if index == 1{
                secondInvitedIcon.isHidden = false
            }else{
                thiredInvitedIcon.isHidden = false
            }
            
            View.backgroundColor = UIColor("#6c62ff")
            View.alpha = 0.4
            label.text = "Invited"
            label.font = UIFont(name: "Avenir-BlackOblique" , size: 14)
            label.textColor = UIColor("#00C0E3")
            
        }
        
    }
    
    fileprivate func setEmptyView(index:Int, label:UILabel){
        if (myGroup == nil && friends.count == 0) || (myGroup?.status == "inactive" && friends.count == 0) {
            label.text = "Import"
        }else{
            label.text = "Invite"
        }
        label.font = UIFont(name: "Avenir-Light" , size: 14)
        label.textColor = UIColor("#666666")
    }
    
    
    fileprivate func getFriends(){
        
        WebServicesManager.shared.getFriendsList { (repsose, error) in
            if error == nil{
                self.friends = EntourageManager.shared.FriendShips
                
                self.setUpView()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    fileprivate func loadGroupActivityVC(friendsIds:[Int],listType:String){
        
        let vc2 = SelectGroupActivityVC.loadSelectGroupActivityVC(firendIds: friendsIds, update: false, listType: listType) { (groupStatus) in
            
            if groupStatus == true{
                self.myGroup = EntourageManager.shared.myGroup
                self.updateView()
            }else{
                //self.addGroupMember()
                self.loadCustomeStatusVC(friendIds: friendsIds)
            }
            
        }

        let sheetController = SheetViewController(controller: vc2, sizes: [.fixed(self.view.frame.height * 0.7 ),.fullScreen])
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = true
        sheetController.extendBackgroundBehindHandle = false
        sheetController.topCornersRadius = 16
        sheetController.handleTopEdgeInset = 0
        sheetController.handleBottomEdgeInset = 0
        sheetController.handleSize = CGSize.zero
        sheetController.handleView.isHidden = true
        
        sheetController.willDismiss = { _ in
            print("Will dismiss ")
        }
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)

        
        
    }
    
    
    fileprivate func changeGroupActivity(friendsIds:[Int],listType:String){
        
        let vc2 = SelectGroupActivityVC.loadSelectGroupActivityVC(firendIds: friendsIds, update: true,listType:listType) { (groupStatus) in
            
            if groupStatus == true{//group status Update or Group Create First Time
                
                self.myGroup = EntourageManager.shared.myGroup
                self.updateView()
            
            }else{// but if user click customStatus Tab
                self.loadCustomeStatusVC(friendIds: friendsIds)
            }
            
        }
        
        let sheetController = SheetViewController(controller: vc2, sizes: [.fixed(self.view.frame.height * 0.7 ),.fullScreen])
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = true
        sheetController.extendBackgroundBehindHandle = false
        sheetController.topCornersRadius = 16
        sheetController.handleView.isHidden = true
        sheetController.handleTopEdgeInset = 0
        sheetController.handleBottomEdgeInset = 0
        sheetController.handleSize = CGSize.zero

        sheetController.willDismiss = { _ in
            print("Will dismiss ")
        }
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)
        
    }
    
    fileprivate func loadCustomeStatusVC(friendIds:[Int]){
        
        let vc = CustomStatusVC.loadCustomStatusVC(friendsIds: friendIds, callback: { (createCustomeStatus,listType)  in
            if createCustomeStatus == true{
                
                self.myGroup = EntourageManager.shared.myGroup
                self.updateView()

            }else{
                self.changeGroupActivity(friendsIds: friendIds, listType: listType)
            }
        })
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fullScreen])
        
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = true
        sheetController.extendBackgroundBehindHandle = false
        sheetController.topCornersRadius = 16
        sheetController.handleView.isHidden = true
        sheetController.handleTopEdgeInset = 0
        sheetController.handleBottomEdgeInset = 0
        sheetController.handleSize = CGSize.zero
        
        sheetController.willDismiss = { _ in
            print("Will dismiss ")
        }
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)

    }
    
    fileprivate func switchToUnActiveProfile(){
        
        Utils.transtion = false
        self.navigationController?.popViewController(animated: false)
        self.callback()
    }
    
    fileprivate func switchToUnActiveScreen(){
        lastMessageListner?.unsubscribe()
        self.switchToUnActiveProfile()
    }
    
    fileprivate func openImportFriendsScreen(status:Bool){
        
        let vc = SearchFriendsVC.loadSearchFriendsVC(flow: status) {
            self.getFriends()
        }
        let VC = UINavigationController(rootViewController: vc)
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)
        
    }
    
}


// MARK: - Actions
extension ActiveProfileVC{
    
    @IBAction func backBtn(sender: UIButton) {
        
        Utils.transtion = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func pressSettingBtn(_ sender: Any) {
        
        if EntourageManager.shared.setting == nil{
            self.startAnimation()
            WebServicesManager.shared.getUserSettings { (response, error) in
                self.stopAnimation()
                
                if error == nil{
                    
                    self.loadSettingVC()
                    
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }
            
        }else{
            self.loadSettingVC()
        }
        
        
        
    }
    
    @IBAction func pressProfileShareBtn(_ sender: Any) {
//        if myGroup?.status == "active"{
//            myGroup?.users.forEach({friendIds.append($0.id) })
//            self.changeGroupActivity(friendsIds: self.friendIds, listType: "Other")
//        }else
        if myGroup == nil || myGroup?.status == "inactive" , friends.count == 0{//APP Share Btn
            let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
            self.present(ac, animated: true)
        }
        
    }
    
    @IBAction func pressStatusBtn(_ sender: Any) {
        if myGroup?.status == "active"{
            myGroup?.users.forEach({friendIds.append($0.id) })
            self.changeGroupActivity(friendsIds: self.friendIds, listType: "Other")
        }
//        else{
//            if myGroup == nil || myGroup?.status == "inactive" , friends.count == 0{//APP Share Btn
//                let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
//                self.present(ac, animated: true)
//            }
//        }
        
    }
    
    @IBAction func pressShareBtn(_ sender: Any) {
    
        let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
        self.present(ac, animated: true)

    }

    @IBAction func pressInActiveGroupShareBtn(_ sender: Any) {
    
        if myGroup == nil || myGroup?.status == "inactive" , friends.count == 0{//APP Share Btn
            let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
            self.present(ac, animated: true)
        }

    }

    @IBAction func pressActiveFriendsBtn(_ sender: Any) {
        self.openImportFriendsScreen(status: true)
    }

    
    @IBAction func pressPremiumBtn(_ sender: Any) {
        self.loadUserProfileVC(user: EntourageManager.shared.user, group: nil)
        
    }
    
    @IBAction func pressImagePickerBtn(_ sender: Any) {
        self.loadUserProfileVC(user: EntourageManager.shared.user, group: nil)
    }
    
    @IBAction func pressEditBtn(_ sender: Any) {
        self.loadEditProfileVC {
            self.updateGUI()
        }
    }


    @IBAction func pressImportBtn(_ sender: Any) {
        
        if myGroup?.status == "active"{
            
            let vc = LeaveGroupAlertVC.loadLeaveGroupAlertVC {
                self.switchToUnActiveScreen()
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
            
            
        }else if myGroup == nil || myGroup?.status == "inactive" , friends.count == 0{//APP Share Btn
            //TODO:-
            let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
            self.present(ac, animated: true)

        }else if myGroup == nil || myGroup?.status == "inactive"{            
            openImportFriendsScreen(status: false)
        }
        
    }
    
    @IBAction func pressInviteBtn(_ sender: Any) {
        
        if myGroup?.status == "active"{
            
            if myGroup?.users.count == 4{
                
                //if Group full of members
                guard let group = EntourageManager.shared.myGroup else{
                    return
                }
                
                Utils.notificationInChatRoom = false
                
                resetUnReadMsg(id: "\(group.id)")
                
                Utils.mainVC?.upadteMessageIcon()
                
                chatListener = MessageFirebaseService.createListener(id: "\(group.id)" )
                activeMemberListner = ActiveMemberFireBaseService.creatActiveListner(id:"\(group.id)"  )
                
                self.loadChatGroupVC(matchId: 0, group: group) { (updateStatus) in
                    
                    if updateStatus == true{
                        self.switchToUnActiveScreen()
                    }
                    
                }
                
                
            }else{ //if Group paritialy filled
                openImportFriendsScreen(status: true)
            }
            
        }else if myGroup == nil || myGroup?.status == "inactive"{
            
            if self.friends.count == 0{
                openImportFriendsScreen(status: false)
            }else{
                addGroupMember()
            }
            
        }
        
    }
    
    
    
    
    @IBAction func pressInvite1Btn(_ sender: UIButton) {
        
        if groupMember.indices.contains(0),myGroup?.allGroupMember().contains(where: {$0.id == groupMember[0].id }) ?? false{
            
            if groupMember[0].isMember == false{//Group Invited Member
                
                let vc = CancelInviteVC.cancelInviteVC(friendId: groupMember[0].id) {
                    self.updateView()
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)

            }else{//Group Actual Member
                
                self.loadUserProfileVC(user: groupMember[0], group: nil)
                //        openImportFriendsScreen(status: false)
            }

        }else if self.friends.count == 0{
            openImportFriendsScreen(status: false)
        }else {
            addGroupMember()
        }
    }
    
    @IBAction func pressInvite2Btn(_ sender: Any) {
        
        if groupMember.indices.contains(1),myGroup?.allGroupMember().contains(where: {$0.id == groupMember[1].id }) ?? false {
            
            
            if groupMember[1].isMember == false{//Group Invited Member
                
                let vc = CancelInviteVC.cancelInviteVC(friendId: groupMember[1].id) {
                    self.updateView()
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)

            }else{//Group Actual Member
                
                self.loadUserProfileVC(user: groupMember[1], group: nil)
                //        openImportFriendsScreen(status: false)

            }
            
        }else if self.friends.count == 0{
            openImportFriendsScreen(status: false)
        }else{
            addGroupMember()
        }
    }
    
    @IBAction func pressInvite3Btn(_ sender: Any) {
        
        if groupMember.indices.contains(2),myGroup?.allGroupMember().contains(where: {$0.id == groupMember[2].id }) ?? false{
        
            if groupMember[2].isMember == false{//Group Invited Member
                
                let vc = CancelInviteVC.cancelInviteVC(friendId: groupMember[2].id) {
                    self.updateView()
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)

            }else{//Group Actual Member
                
                self.loadUserProfileVC(user: groupMember[2], group: nil)
                //        openImportFriendsScreen(status: false)

            }
            
        }else if self.friends.count == 0{
            openImportFriendsScreen(status: false)
        }else{
            addGroupMember()
        }
        
    }
    
    @objc func FirstInviteBtn(){
        
        if groupMember.indices.contains(0),groupMember[0].isMember == false{
            
            let vc = CancelInviteVC.cancelInviteVC(friendId: groupMember[0].id) {
                self.updateView()
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @objc func SecInviteBtn(){
        
        if groupMember.indices.contains(1),groupMember[1].isMember == false{
            
            let vc = CancelInviteVC.cancelInviteVC(friendId: groupMember[1].id) {
                self.updateView()
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @objc func ThirdInviteBtn(){
        if groupMember.indices.contains(2),groupMember[2].isMember == false{
            
            let vc = CancelInviteVC.cancelInviteVC(friendId: groupMember[2].id) {
                self.updateView()
            }
            
            vc.modalPresentationStyle = .overCurrentContext
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    fileprivate func addGroupMember(){
        
        let vc = AddGroupMemberVC.loadAddGroupMemberVC(callback: { (friendIds) in
            
            if friendIds.isEmpty == true{ //member is added in old group so its only updated
                self.myGroup = EntourageManager.shared.myGroup
                self.updateView()
            }else if friendIds[0] == -1{//when no friend avaliable so we have to open FriendsImport screen
                self.openImportFriendsScreen(status: false)
            }else if friendIds[0] == -2{//Invite Cancel Opertation Occuers on AddGroupMember Screen
                self.updateView()
            }else{// added members in new Group First time.
                self.loadGroupActivityVC(friendsIds: friendIds, listType: "Other")
            }

            
        })
        
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(self.view.frame.height * 0.7 ),.fullScreen])
        
        sheetController.adjustForBottomSafeArea = false
        sheetController.blurBottomSafeArea = false
        sheetController.dismissOnBackgroundTap = true
        sheetController.extendBackgroundBehindHandle = false
        sheetController.topCornersRadius = 16
        sheetController.handleView.isHidden = true
        sheetController.handleTopEdgeInset = 0
        sheetController.handleBottomEdgeInset = 0
        sheetController.handleSize = CGSize.zero

        //sheetController.dismissOnPan = false

                
        sheetController.willDismiss = { _ in
            print("Will dismiss ")
        }
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)
        
        
    }
    
    
}

//MARK: - UICollectionDataSource
//extension ActiveProfileVC : UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView == self.premiumCollectionView{
//            
//            return premiumTextArray.count
//        }else{
//            return 4
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        if collectionView == self.premiumCollectionView{
//            
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveProfileVCPremiumCell", for: indexPath) as! ActiveProfileVCPremiumCell
//            
//            cell.cellText.text = premiumTextArray[indexPath.row]
//            cell.titleImage.image =  UIImage(named: premiumImageArray[indexPath.row])
//            
//            return cell
//            
//        }else{
//            
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ActiveProfileVCGroupCell", for: indexPath) as! ActiveProfileVCGroupCell
//            
//            if indexPath.row == 0 {
//                cell.contenView.addSubview(GroupCardViewOne(frame: CGRect(x: 0, y: 0, width: (self.view.frame.width - 5) / 3 , height: 180),space:4))
//            }else if indexPath.row == 1{
//                cell.contenView.addSubview(GroupCardViewTwo(frame: CGRect(x: 0, y: 0, width: (self.view.frame.width - 5) / 3 , height: 180),space:4))
//            }else{
//                cell.contenView.addSubview(GroupCardViewThree(frame: CGRect(x: 0, y: 0, width: (self.view.frame.width - 5) / 3 , height: 180),space:4))
//            }
//            
//            cell.maximimizeIcon.isHidden = false
//            
//            return cell
//            
//        }
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView == self.premiumCollectionView{
//            return CGSize(width: (self.view.frame.width - 40) , height: 120)
//        }else{
//            return CGSize(width: (self.view.frame.width - 30) / 3 , height: 180)
//            
//        }
//    }
//    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        
//        if (premiumCollectionView.isScrollEnabled == true) {
//            pageIndex = Int(targetContentOffset.pointee.x / (view.frame.width - 40))
//            pageController.currentPage = pageIndex
//            pageController.customPageControlNewDesgin(dotFillColor: UIColor("#D2D2D2"), dotBorderColor: UIColor("#6C62FF"), dotBorderWidth: 2)
//        }
//    }
//    
//}
//
//
//// MARK: - UICollectionViewDelegate
//extension ActiveProfileVC : UICollectionViewDelegate{
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if collectionView == self.groupCollectionView{
//            //            let cell =  self.groupCollectionView.cellForItem(at: indexPath) as! ActiveProfileVCGroupCell
//            self.loadLikedGroupVC()
//        }
//    }
//}
//

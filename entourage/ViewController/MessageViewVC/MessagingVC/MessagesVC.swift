//
//  MessagesVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/30/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FittedSheets

protocol messageingViewUpdation {
    func updateMatchList()
}


class MessagesVC: BaseVC{
    
    //MARK: - IBOutLets
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var profileGroupView: UIView!
    @IBOutlet weak var groupChatTitle: UILabel!
    @IBOutlet weak var groupChatMessage: UILabel!
    @IBOutlet weak var groupMessageIcon: UIImageView!
    @IBOutlet weak var groupChatView: UIView!
    @IBOutlet weak var profileGroupImageView: UIImageView!
    @IBOutlet weak var groupSecMemberImage: UIImageView!
    @IBOutlet weak var groupThirdMemberImage: UIImageView!
    @IBOutlet weak var groupFourthMemberImage: UIImageView!
    @IBOutlet weak var msgIcon: UIImageView!
    @IBOutlet weak var replyIconWidth: NSLayoutConstraint!
    @IBOutlet weak var replyIconHeight: NSLayoutConstraint!
    @IBOutlet weak var groupNewMessageIcon: UIImageView!

    //Work Remaining
    @IBOutlet weak var matchesLabel: UILabel!
    @IBOutlet weak var groupNumLbl: UILabel!
    
    @IBOutlet weak var nonEmptyView: UIView!
    @IBOutlet weak var messageEmptyView: UIView!
    @IBOutlet weak var messageTableView: UITableView!
    
    @IBOutlet weak var messageEmptyImg: UIImageView!
    @IBOutlet weak var messageEmptyTitle: UILabel!
    @IBOutlet weak var messageEmptyDesc: UILabel!
    
    //premium Add
    @IBOutlet weak var likedGroupProfileView: UIView!
    @IBOutlet weak var numberOfLikes: UILabel!
    
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var notificationEmptyView: UIView!
    @IBOutlet weak var notificationTableView: UITableView!
    
    @IBOutlet weak var topViewheight : NSLayoutConstraint!
    
    
    //MARK:- Class Properties
    var messageTableViewDataSource = MessageTableView()
    
    let user = EntourageManager.shared.user
    let notificationTableViewDataSource = NotificationTableView()
    var matchList : [Match] = EntourageManager.shared.myMatchs
    var callback : PressOkay!
    var lastMessage : [LastMessage] = []
    
    
    override func setupGUI() {
        super.setupGUI()
        
        self.hideNavBar()
        
        topViewheight.constant = 30 + Constants.statusBarHeight
        
        notificationView.isHidden = true
        messageEmptyView.isHidden = true

        self.messageTableView.dataSource = messageTableViewDataSource
        self.messageTableView.delegate = messageTableViewDataSource
        
        self.messageTableView.estimatedRowHeight = 98
        self.messageTableView.rowHeight = UITableView.automaticDimension
        
        self.notificationTableView.estimatedRowHeight = 60
        self.notificationTableView.rowHeight = UITableView.automaticDimension
        
        
        self.notificationTableView.dataSource = notificationTableViewDataSource
        self.notificationTableView.reloadData()
        
        
        self.checkNotification()
        
        self.numberOfLikes.text = "0+"
        
        //self.groupChatView.setBottomShadow()
        
        if EntourageManager.shared.myGroup != nil,EntourageManager.shared.myGroup?.status == "active"{
            getMatchGroup()
        }else{
            updateView()
        }
        
        
    }

    override func updateGUI() {
        
        self.title = "Message"
        Utils.currVC = self
        
        updateView()
    }
    
    fileprivate func checkNotification(){
        
        let number = UserDefaults.standard.object(forKey: "num") as? Int ?? 0
        
        if number < 1{
            
            UserDefaults.standard.set(number+1, forKey: "num")
            
            Utils.checkNotificationAuthorizationStatus { (status , value)  in
                if status == false{
        
                    Utils.notification = false
                    DispatchQueue.main.async {

                        let vc = NotificationsPermissionVC().loadNotificationsPermissionVC {
                            
                        }
                        
                        let nvc = UINavigationController(rootViewController: vc)
                        nvc.modalPresentationStyle = .fullScreen
                        self.present(nvc, animated: true, completion: nil)

                    }
                    
                }
            }
        }
    }
    
    
    fileprivate func removeDocument(docId:String){
        deleteTheChatMessage(groupId:docId) {
            deleteTheChatMember(groupId: docId) {
                
                lastMessageListner?.delete(docId: docId, completion: { (error) in
                    if error != nil{
                        self.stopAnimation()
                        self.showAlert(title: "Error", message: error?.localizedDescription ?? "")
                    }else{
                        self.stopAnimation()
                        self.setupGUI()
                    }
                })
            }
        }

    }
    
    
    fileprivate func updateView(){
        
        self.matchList = EntourageManager.shared.myMatchs

        self.setUpTheMessageFlow()
        self.updateMyGroupView()

        self.messageTableViewDataSource.vc = self
        self.messageTableView.reloadData()
        
    }
    
    fileprivate func getMatchGroup(){
        messageEmptyView.isHidden = true
                
        WebServicesManager.shared.matchList { (list, error) in
            
            if error == nil{
                
                guard let matchList = list as? [Match] else{
                    return
                }
            
                self.matchList = matchList
                        
                if self.matchList.count == 0,EntourageManager.shared.myGroup == nil{
                    lastMessageListner?.unsubscribe()
                }
                        
                
                self.updateView()
                
            }else{
                self.showAlert(title: "Error", message:error!)
            }
        }
    }
    
    func UnMatch(groupId:Int, index:Int){
        self.startAnimation()
        WebServicesManager.shared.unMatchTheGroup(groupId: "\(groupId)") { (response, error) in
            
            if error == nil{
                
                //remove User his Last Msg
                removeMyMsg(id: "Match_\(groupId)")
                //Remove User Chat Last Msg
                removeLastMsg(id: "Match_\(groupId)")
                //minus his usread msg from msg Counter
                decrementUnReadMsgCounter(value: getUnReadMsg(id: "\(groupId)") )
                //remove from User Default
                removeUnReadMsg(id: "Match_\(groupId)" )
                
                removeLastSender(key: "Match_\(groupId)")
                
                
                EntourageManager.shared.myMatchs.remove(at: index)
                self.matchList = EntourageManager.shared.myMatchs
                self.setUpTheMessageFlow()
                self.updateMyGroupView()
                
                self.removeDocument(docId: "Match_\(groupId)")
                
                Utils.updateMyGroup = true
                
            }else{
                self.stopAnimation()
                self.showAlert(title: "Error", message:error!)
            }
            
        }
    }
    
    
    fileprivate func updateMyGroupView(){
        
        replyIconWidth.constant = 0
        
        if EntourageManager.shared.myGroup == nil || EntourageManager.shared.myGroup?.status ?? "" != "active"{
            
            self.emptyGroupView()
            self.emptyMatchView()
            return
        }

        guard let group = EntourageManager.shared.myGroup else{
            return
        }
        

        if self.matchList.isEmpty {
            self.emptyMatchView()
        }
        
        groupChatMessage.font = UIFont(name: "Avenir-Roman", size: 16)
        groupChatMessage.textColor = UIColor("#666666")
        replyIconWidth.constant = 0
        replyIconHeight.constant = 0

        let chatId = "\(group.id)"
        _ = getMyMsg(id: chatId )
        let groupLastMessage = getLastMsg(id:chatId)
        let senderId = getLastSender(key: chatId)
        _ = group.users.filter({$0.id == senderId})

        groupChatTitle.text = group.myGroupName()//sender.first?.first_name ?? ""

        for (index) in 0..<4{
            
            if group.users.indices.contains(index) {
                
                if index == 0{
                    self.setUpUserPhoto(user: group.users[0], imageView: profileGroupImageView)
                }else if index == 1{
                    self.setUpUserPhoto(user: group.users[1], imageView: groupSecMemberImage)
                }else if index == 2{
                    self.setUpUserPhoto(user: group.users[2], imageView: groupThirdMemberImage)
                }else{
                    self.setUpUserPhoto(user: group.users[3], imageView: groupFourthMemberImage)
                }

            }else{

                if index == 1{
                    groupSecMemberImage.isHidden = true
                }else if index == 2{
                    groupThirdMemberImage.isHidden = true
                }else{
                    groupFourthMemberImage.isHidden = true
                }

            }
            
        }

        groupChatView.backgroundColor = .white//UIColor("#00C0E3").withAlphaComponent(0.1)

        if  /*myMessage.isEmpty,*/ groupLastMessage.isEmpty {// if groupMsg List is empty and i did not msg in Group until now.

            groupChatTitle.text = "Private Chat"
            groupChatView.backgroundColor = .white//UIColor("#59609C").withAlphaComponent(0.1)

            replyIconWidth.constant = 16
            replyIconHeight.constant = 16
            msgIcon.image = UIImage(systemName:"paperplane.fill")

            groupChatMessage.font = UIFont(name: "Avenir-Medium", size: 16)
            groupChatMessage.textColor = UIColor("#00C0E3")
            groupChatMessage.text = "  Send a Message"
                        
        }else if getLastSender(key: chatId) == user.id {

            replyIconWidth.constant = 12
            replyIconHeight.constant = 8
            msgIcon.image = UIImage(named: "replyIcon")
            groupChatMessage.text = "  \(groupLastMessage)"
            
        }else{
            groupChatMessage.text = "\(groupLastMessage)"
        }
        
    }
    
    fileprivate func setUpUserPhoto(user:User,imageView:UIImageView){
        
        let photo = user.photos.filter({$0.is_primary == true})
        imageView.contentMode = .scaleAspectFill
        
        if photo.count > 0{
            if let url = URL(string: photo[0].medium ?? ""){
                setupThumnail(url: url, IV: imageView)
            }
            
        }else{
            imageView.image = UIImage(named: "defaultImg")
        }
        
    }

    
}


// MARK: - Actions
extension MessagesVC{
    
    func setUpTheMessageFlow(){
//        self.messageView.isHidden = false
//        self.messageEmptyView.isHidden = self.matchList.count > 0 ? true : false
        
        let id = EntourageManager.shared.myGroup?.id ?? 0
        groupNewMessageIcon.isHidden = getUnReadMsg(id: "\(id)" ) > 0 ? false : true//"Group Chat (\(getUnReadMsg(id: "\(id)")))" : "Group Chat"
//       self.groupNumLbl.textColor = getUnReadMsg(id: "\(id)" ) > 0 ? Colors.themeColor.value : UIColor("#D2D2D2")
        
        self.matchesLabel.text = (getAllUnReadMsg() > 0 && self.matchList.count > 0) ? "Messages (\(getAllUnReadMsg()))" : "Messages (0)"
        self.matchesLabel.textColor = (getAllUnReadMsg() > 0 && self.matchList.count > 0) ? Colors.themeColor.value : UIColor("#D2D2D2")
    }
    
    func setTheNotificationFlow(){
        self.notificationView.isHidden = false
        self.messageView.isHidden = true
        self.notificationEmptyView.isHidden = false
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.notificationEmptyView.isHidden = true
        }
    }
    
    fileprivate func addGroupMember(){
        
        let vc = AddGroupMemberVC.loadAddGroupMemberVC(callback: { (friendIds) in
            
            if friendIds.isEmpty == false{
                self.loadGroupActivityVC(friendsIds: friendIds,listType: "Other")
            }
        })
        
        
        var options = SheetOptions()
        options.pullBarHeight = 0
        options.shouldExtendBackground = false
        options.useFullScreenMode = false
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(self.view.frame.height * 0.7 ),.fullscreen], options: options)
        
        sheetController.cornerRadius = 16
        sheetController.dismissOnOverlayTap = true
        sheetController.contentViewController.pullBarView.isHidden = true
                
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
    fileprivate func openImportFriendsScreen(status:Bool){
        
        let vc = SearchFriendsVC.loadSearchFriendsVC(flow: status) {
            self.getFriends()
        }
        let VC = UINavigationController(rootViewController: vc)
        VC.modalPresentationStyle = .fullScreen
        self.present(VC, animated: true, completion: nil)

    }

    fileprivate func getFriends(){
        
        WebServicesManager.shared.getFriendsList { (repsose, error) in
            if error == nil{
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }

    
    fileprivate func loadGroupActivityVC(friendsIds:[Int],listType: String){
        
        let vc = SelectGroupActivityVC.loadSelectGroupActivityVC(firendIds: friendsIds, update: false, listType: listType) { (groupStatus) in
            
            if groupStatus == true{
                self.updateView()
                self.updateGroup()
                                
            }else{
                //self.addGroupMember()
                self.loadCustomeStatusVC(friendIds: friendsIds)
            }
            
        }
        
        
        var options = SheetOptions()
        options.pullBarHeight = 0
        options.shouldExtendBackground = false
        options.useFullScreenMode = false
        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(self.view.frame.height * 0.7 ),.fullscreen], options: options)
        
        sheetController.cornerRadius = 16
        sheetController.dismissOnOverlayTap = true
        sheetController.contentViewController.pullBarView.isHidden = true
                
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)

    }
    
    fileprivate func loadCustomeStatusVC(friendIds:[Int]){
        
        let vc = CustomStatusVC.loadCustomStatusVC(friendsIds: friendIds, callback: { (createCustomeStatus,listType)  in
            if createCustomeStatus == true{
                
                self.updateView()
                self.updateGroup()

            }else{
                self.loadGroupActivityVC(friendsIds: friendIds, listType: listType)
            }
        })
        
        
        var options = SheetOptions()
        options.pullBarHeight = 0
        options.shouldExtendBackground = false
        options.useFullScreenMode = false
        let sheetController = SheetViewController(controller: vc, sizes: [.fullscreen], options: options)
        
        sheetController.cornerRadius = 16
        sheetController.dismissOnOverlayTap = true
        sheetController.contentViewController.pullBarView.isHidden = true
                
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
//        sheetController.adjustForBottomSafeArea = false
//        sheetController.blurBottomSafeArea = false
//        sheetController.dismissOnBackgroundTap = true
//        sheetController.extendBackgroundBehindHandle = false
//        sheetController.topCornersRadius = 16
//        sheetController.handleView.isHidden = true
//        sheetController.handleTopEdgeInset = 0
//        sheetController.handleBottomEdgeInset = 0
//        sheetController.handleSize = CGSize.zero
        
        self.present(sheetController, animated: false, completion: nil)
    }
    
    fileprivate func updateGroup(){
        self.callback()
    }
    
}

//MARK: - Actions
extension MessagesVC{
    @IBAction func pressGroupChatBtn(_ sender: Any) {
        
        if EntourageManager.shared.myGroup == nil || EntourageManager.shared.myGroup?.status != "active"{
            
            if EntourageManager.shared.FriendShips.count > 0{
                self.addGroupMember()
            }else{
                openImportFriendsScreen(status: false)
                //self.addGroupMember()
            }
            
        }else{
            
            guard let group = EntourageManager.shared.myGroup else{
                return
            }
            
            Utils.notificationInChatRoom = false

            resetUnReadMsg(id: "\(group.id)")
            
            self.setUpTheMessageFlow()
            Utils.mainVC?.upadteMessageIcon()
            
            chatListener = MessageFirebaseService.createListener(id: "\(group.id)" )
            activeMemberListner = ActiveMemberFireBaseService.creatActiveListner(id:"\(group.id)"  )
                        
            self.loadChatGroupVC(matchId: 0, group: group) { (updateStatus) in
                
                if updateStatus == true{
                    self.updateView()
                }
            }
        }
        
        
    }
    
    @IBAction func pressAddBtn(_ sender: Any) {
        //self.loadPremiumVC()
    }
    
    @IBAction func pressEnableNotificationBtn(_ sender: Any) {
        openBrowserWith(url: UIApplication.openSettingsURLString)
    }
    
    @IBAction func pressClearBtn(_ sender: Any) {
        
    }
    
    @IBAction func backBtn(sender: UIButton) {
        Utils.transtion = true
        self.navigationController?.popViewController(animated: true)
    }
    
}



// MARK: - messageingViewUpdation
extension MessagesVC : messageingViewUpdation{
    func updateMatchList() {

        self.updateView()
    }

}


// MARK: - EmptyState
extension MessagesVC{
    
    private func emptyGroupView(){
        
        messageEmptyView.isHidden = false
        replyIconWidth.constant = 0
        replyIconHeight.constant = 0
        groupChatTitle.text = "Create a Group"
        groupChatMessage.text = "Send Messages to your Group here"
        groupChatMessage.font = UIFont(name: "Avenir-Roman", size: 16)
        groupChatMessage.textColor = UIColor("#666666")
        groupSecMemberImage.isHidden = true
        groupThirdMemberImage.isHidden = true
        groupFourthMemberImage.isHidden = true

        groupChatView.backgroundColor = .white
        profileGroupImageView.contentMode = .scaleAspectFit
        profileGroupImageView.image = UIImage(named: "groupCreated")
        
        groupChatTitle.textColor = UIColor("#878F96")
        messageEmptyImg.image = UIImage(named: "noGroup")!
        messageEmptyTitle.text = "Create a Group"
        messageEmptyDesc.text = "You must create or be invited to a group to message others."
        
    }
    
    private func emptyMatchView(){
        
        messageEmptyView.isHidden = false
        messageEmptyImg.image = UIImage(named: "emptyMatch")!
        messageEmptyTitle.text = "Start Swiping"
        messageEmptyDesc.text = "Once you match, you can message them here."
    }
    
}


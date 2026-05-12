//
//  SwipeActiveFriendsVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/30/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Koloda
import HGRippleRadarView
import AVFoundation
import CoreLocation
import FittedSheets
import RSSelectionMenu


class SwipeFriendsVC: BaseVC {
    
    //MARK: - IBOutLets
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var btnView: UIView!
    @IBOutlet weak var enableBtnView: UIView!
    @IBOutlet weak var newTopView: UIView!
    @IBOutlet weak var topTitleImage: UIImageView!
    
    @IBOutlet weak var demoView: UIView!
    @IBOutlet weak var demoAnimateImage: UIImageView!
    @IBOutlet weak var demoTabContinue : UIButton!
    
    @IBOutlet weak var inviteNewMemberBtn: UIButton!
    @IBOutlet weak var radarView: UIView!
    @IBOutlet weak var importFriendCardView: ImportFriendView!
    @IBOutlet weak var addFriendCardView: AddFriendsView!
    @IBOutlet weak var radarDiskView: RadarView!
    @IBOutlet weak var friendListView : UIView!
    @IBOutlet weak var msgsBtn : UIButton!
    @IBOutlet weak var newMsgIcon : UIView!
    @IBOutlet weak var qucikMatch : UIButton!
    @IBOutlet weak var undoBtn : UIButton!
    @IBOutlet weak var spotLight : UIButton!
    
    @IBOutlet weak var serachFilterBtn : UIButton!
    @IBOutlet weak var emptyOtherGroupMsg : UILabel!
    
    @IBOutlet weak var myMember3Width : NSLayoutConstraint!
    @IBOutlet weak var myMember4Width : NSLayoutConstraint!
    @IBOutlet weak var spotLightTimerView : CircularProgressView!
    @IBOutlet weak var spotLightTimerLbl : UILabel!
    
    //MARK:- Class Properties
    var player: AVAudioPlayer?
    
    var cardView : [UIView] = []
    var friends : [Friend] = []
    var otherGroups : [Group] = []
    var currCardGroup : Group?
    var instantMatch : Bool = false
    let user = EntourageManager.shared.user
    var delegate : messageingViewUpdation?
    
    private var timer = Timer()
    private var timeRemaining = 0
    private var totalTime = 0
    private var cardsPagination = Pagination()
    var pageIndex = 1
    
    var cardsSwipeLimit = ["0.1","0.2","0.3","0.4","0.5","0.6","0.7","0.8","0.9","1.0"]
    var cardSwipeLimitSelectedIndex = 3
    
    override func setupGUI() {
        super.setupGUI()
        
        self.hideNavBar()
        
        self.demoView.isHidden = true
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        kolodaView.appearanceAnimationDuration = 0.0
        //kolodaView.swipeLimit = Float(cardsSwipeLimit[cardSwipeLimitSelectedIndex]) ?? 0.4
        
        radarDiskView.animationDuration = 0.8
        setRadarView(status: true)
        
        radarView.isHidden = false
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            print("No access")
        case .authorizedAlways, .authorizedWhenInUse:
            self.myGroup{
                self.checkRemainingNotifcation()
                //self.loadGroupMatchedVC(group: EntourageManager.shared.myGroup!, matchType: "") {}
            }
        @unknown default:
            fatalError()
        }
        
        self.btnView.isHidden = true
        self.spotLightTimerView.isHidden = true
        
        self.kolodaView.isHidden = true
        self.friendListView.isHidden = true
        
        self.kolodaView.backgroundCardsTopMargin = 0
        self.kolodaView.countOfVisibleCards = 0
        
        self.undoBtn.isHidden = false
        if currCardGroup == nil{
            self.undoBtn.isHidden = true
        }
        
        
        self.view.setGradientBackground(colorOne: UIColor.white, colorTwo: UIColor("#f6f7fb"))
    }
    
    override func updateGUI() {
        
        self.friends = EntourageManager.shared.FriendShips
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined, .restricted, .denied:
            // Show alert letting the user know they have to turn this on.
            let vc = LocationPermissionVC.loadLocationPermissionVC {
                self.myGroup{
                    self.checkRemainingNotifcation()
                }
            }
            let rootVC = UINavigationController(rootViewController:vc )
            rootVC.modalPresentationStyle = .fullScreen
            self.present(rootVC, animated: true, completion: nil)
            
        case .authorizedAlways, .authorizedWhenInUse:
            print("Access")
            if user.latitude == nil ,user.longitude == nil{
                
                let vc = LocationPermissionVC.loadLocationPermissionVC {
                    self.myGroup{
                        self.checkRemainingNotifcation()
                    }
                }
                let rootVC = UINavigationController(rootViewController:vc )
                rootVC.modalPresentationStyle = .fullScreen
                self.present(rootVC, animated: true, completion: nil)
                
            }
            
        @unknown default:
            fatalError()
        }
        
        
        if let type = UserDefaults.standard.object(forKey: "notifiable_type") as? String{
            if type == "Message"{
                Utils.appOpenForNotification = true
            }
        }
        
        Utils.mainVC = self
        Utils.currVC = self
        self.upadteMessageIcon()
        
        updateView()
        
    }
    
    private func updateView(){
        
        if Utils.updateMyGroup == true{
            
            myGroup{
                Utils.updateMyGroup = false
            }
            
        }else{
            
            self.setTopView()
        }
        
    }
    
    func upadteMessageIcon(){
        
        let myGroupId = EntourageManager.shared.myGroup?.id ?? 0
        
        let totalUNreadCounter = ( getAllUnReadMsg() + getUnReadMsg(id: "\(myGroupId)" ) )
        newMsgIcon.isHidden = totalUNreadCounter > 0 ? false : true
        
        //When 5 unread Msg are avalible then Animation start
        if totalUNreadCounter > 5{
            newMsgIcon.NewMsgIconpulsate()
        }else{
            newMsgIcon.layer.removeAnimation(forKey: "pulse")
        }
    }
    
    private func swipeDemo(type:String){
        demoView.isHidden = false
        if type == "Like"{
            demoTabContinue.tag = 222
            demoAnimateImage.image = UIImage(named: "swipeRight")
        }else{
            demoTabContinue.tag = 333
            demoAnimateImage.image = UIImage(named: "swipeLeft")
        }
        
    }
    
    fileprivate func checkRemainingNotifcation(){
        
        if let type = UserDefaults.standard.object(forKey: "notifiable_type") as? String{
            
            switch type
            {
            case "Message":
                showChatScreen {
                    self.showGroupInviteRequest(index: 0)
                }
                break
            case "MatchCreated":
                self.showMatchScreen {
                    self.showGroupInviteRequest(index: 0)
                }
                break
            case "FriendshipRequest":
                UserDefaults.standard.removeObject(forKey: "notifiable_type" )
                self.openImportFriendsVC()
                break
            case "FriendshipAccepted":
                UserDefaults.standard.removeObject(forKey: "notifiable_type" )
                self.openImportFriendsVC()
                break
            default:
                self.showGroupInviteRequest(index: 0)
                break
            }
            
        }else{
            showGroupInviteRequest(index: 0)
        }
        
    }
    
    fileprivate func showChatScreen(completeion:@escaping()->Void){
        
        guard let chat_Id = UserDefaults.standard.object(forKey: "chat_id") as? Int  else {
            completeion()
            return
        }
        
        guard let group_id = UserDefaults.standard.object(forKey: "group_id") as? Int  else {
            completeion()
            return
        }
        
        
        self.startAnimation()
        WebServicesManager.shared.getGroupBy(groupId: group_id) { (groupBase, error) in
            self.stopAnimation()
            
            if error == nil{
                
                guard  let group = groupBase as? Group else{
                    completeion()
                    return
                }
                
                
                UserDefaults.standard.removeObject(forKey: "notifiable_type" )
                UserDefaults.standard.removeObject(forKey: "chat_id" )
                UserDefaults.standard.removeObject(forKey: "group_id" )
                
                var roomId = 0
                
                if group.users.contains(where: {$0.id == EntourageManager.shared.user.id}) == false{
                    
                    roomId = chat_Id
                }
                
                self.openChatVC(chatId: roomId , group: group, completeion: {
                    
                })
                
                completeion()
            }else{
                self.showAlert(title: "Error", message: error!)
                completeion()
            }
            
        }
        
    }
    
    fileprivate func showMatchScreen(completeion:@escaping()->Void){
        guard let match_Id = UserDefaults.standard.object(forKey: "chat_id") as? Int  else {
            completeion()
            return
        }
        
        self.matchInvite(matchId: match_Id ) {
            UserDefaults.standard.removeObject(forKey: "notifiable_type" )
            UserDefaults.standard.removeObject(forKey: "match_id" )
            completeion()
        }
        
    }
    
    fileprivate func showGroupInviteRequest(index:Int){
        
        let groupRequest = EntourageManager.shared.groupInviteRequestes
        
        if index >= groupRequest.count{
            EntourageManager.shared.groupInviteRequestes = []
            UserDefaults.standard.removeObject(forKey: "notifiable_type" )
            return
        }
        
        let vc = GroupInviteVC.groupInviteVC(groupInvitedId: groupRequest[index].id ){ (status) in
            if status{
                EntourageManager.shared.groupInviteRequestes = []
                self.loadSwipeFriendsVC()
            }else{
                self.showGroupInviteRequest(index: index+1)
            }
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    func setUpSwipeCardView(group:Group) -> SwipeCards{
        let  view = SwipeCards(frame: .zero, group: group)
        
        view.firstMemberBtn.addTarget(self, action: #selector(pressFirstMemberBtn), for: .touchUpInside)
        view.secondMemberBtn.addTarget(self, action: #selector(pressSecondMemberBtn), for: .touchUpInside)
        view.thirdMemberBtn.addTarget(self, action: #selector(pressThirdMemberBtn), for: .touchUpInside)
        view.fourMemberBtn.addTarget(self, action: #selector(pressFourMemberBtn), for: .touchUpInside)

        view.reportBtn.addTarget(self, action: #selector(pressGroupReportBtn), for: .touchUpInside)

        
        return view
    }
    
    func setUpImportView(){
        importFriendCardView.isHidden = false
        importFriendCardView.importFriendsBtn .addTarget(self, action: #selector(pressImportFriends), for: .touchUpInside)
        importFriendCardView.linkBtn.addTarget(self, action: #selector(pressLinkBtn), for: .touchUpInside)
        importFriendCardView.shareBtn.addTarget(self, action: #selector(pressShareUserNameBtn), for: .touchUpInside)
        
        addFriendCardView.isHidden = true
        kolodaView.isHidden = true
        btnView.isHidden = true
        spotLightTimerView.isHidden = true
        spotLightTimerLbl.text = ""
    }
    
    func setUpAddFriendView(){
        addFriendCardView.isHidden = false
        addFriendCardView.addFriendsBtn.addTarget(self, action: #selector(pressAddFriendsBtn), for: .touchUpInside)
        addFriendCardView.importFriendsBtn .addTarget(self, action: #selector(pressImportFriends), for: .touchUpInside)
        addFriendCardView.openAppLink.addTarget(self, action: #selector(pressLinkBtn), for: .touchUpInside)
        
        
        importFriendCardView.isHidden = true
        kolodaView.isHidden = true
        btnView.isHidden = true
        spotLightTimerView.isHidden = true
        spotLightTimerLbl.text = ""
        
    }
    
    private func loadInstantMatchPreviewView(){
        
        UserDefaults.standard.set(true, forKey: iMatchUserDefaultKey)

        let vc = PreviewVC.loadPreviewVC(previewType: "iMatch") {
            
            if EntourageManager.shared.user.instantMatchAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.instantMatchAllow ?? 0 > 0 {
                self.instantMatch = true
                self.kolodaView?.swipe(.right)
            }
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    private func loadSpotLitePreviewView(){
        
        UserDefaults.standard.set(true, forKey: spotLiteUserDefaultKey)
        
        let vc = PreviewVC.loadPreviewVC(previewType: "spotLight") {
            if EntourageManager.shared.user.spotLightAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.spotLightAllow ?? 0 > 0{
                self.notificationFeedBackBtn(.success)
                self.spotLiteApiCall()
            }
        }
        
        present(vc, animated: true, completion: nil)
    }
    
    fileprivate func addGroupMember(){
        
        let vc = AddGroupMemberVC.loadAddGroupMemberVC(callback: { (friendIds) in
            
            if friendIds.isEmpty == true{
                self.updateView()
            }else if friendIds[0] == -1{
                self.pressImportFriends()
            }else if friendIds[0] == -2{//Invite Cancel Opertation Occuers on AddGroupMember Screen
                self.updateView()
            }else{
                self.loadGroupActivityVC(friendsIds: friendIds, listType: "Other")
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
    
    private func resetSetTheCard(groupId:String){
        self.startAnimation()
        WebServicesManager.shared.resetOtherGroupStatus(groupId:groupId) { (message, error) in
            self.stopAnimation()
            if error == nil{
                self.currCardGroup = nil
                self.undoBtn.isHidden = true
                
                // self.getOtherGroups()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    private func cardSwipeAction(type:String){
        
        if type == "undo"{
            
            let previousOtherGroupId = currCardGroup?.id ?? 0
            
            //if Like group is Already in my matched Group then its no reverted back
            if EntourageManager.shared.myMatchs.contains(where: {$0.matcher?.id ?? -1 == previousOtherGroupId}) == false{
                self.resetSetTheCard(groupId: "\(previousOtherGroupId)")
                kolodaView.revertAction()
            }
            
        }else if type == "unLike"{
            
            kolodaView?.swipe(.left)
            
        }else if type == "spotLight"{

            if UserDefaults.standard.bool(forKey: spotLiteUserDefaultKey){ // if its preView is already showed

                if EntourageManager.shared.user.spotLightAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.spotLightAllow ?? 0 > 0{
                    notificationFeedBackBtn(.success)
                    self.spotLiteApiCall()
                }

            }else{ self.loadSpotLitePreviewView() }
            
        }else if type == "Like"{
            
            instantMatch = false
            kolodaView?.swipe(.right)
            
        }else if type == "iMatch"{
            
            if UserDefaults.standard.bool(forKey: iMatchUserDefaultKey){ // if its preView is already showed

                if EntourageManager.shared.user.instantMatchAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.instantMatchAllow ?? 0 > 0 {
                    self.instantMatch = true
                    self.kolodaView?.swipe(.right)
                }

            }else{

                self.loadInstantMatchPreviewView()
            }
            
        }
        
    }
    
    private func instantMatch(groupId:String){
        WebServicesManager.shared.instantMatch(groupId: groupId) { (match, error) in
            
            if error == nil{
                
                guard let match = match as? Match else{
                    return
                }
                
                
                if match.status == "match"{
                    self.undoBtn.isHidden = true
                    //self.playSound(name: "newmatch")
                    self.notificationFeedBackBtn(.success)
                    EntourageManager.shared.myMatchs.append(match)
                    
                    self.loadGroupMatchedVC(group: match.matcher!, matchType: "instant") {
                        self.openChatVC(chatId: match.chat_id , group: match.matcher!) {
                            
                        }
                        
                    }
                    
                }
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
            
        }
    }
    
    fileprivate func currentGroup(group:Group){
        
        var images : [String] = []
        
        let selectedMember = group.users.filter({$0.id != user.id})
        
        
        selectedMember.forEach({images.append($0.getPrimaryImageThumb())})
        
        self.inviteNewMemberBtn.isHidden = selectedMember.count == 3 ? true : false
        
        for index in 0...2{
            
            let image = getImageViewWith(tag: index+5 , view: self.view)
            let view = getViewWith(tag: index+1 , view: self.view)
            
            if index+1 <= images.count{
                
                if index+1 == 2{
                    myMember3Width.constant = 40
                }else if index+1 == 3{
                    myMember4Width.constant = 40
                }
                
                view.isHidden = false
                if let url = URL(string:images[index]){
                    image.kf.indicatorType = .activity
                    //image.kf.setImage(with: url)
                    setupThumnail(url: url, IV: image)
                }
            }else{
                
                if index+1 == 2{
                    myMember3Width.constant = 16
                }else if index+1 == 3{
                    myMember4Width.constant = 16
                }
                
                image.image = UIImage(named: "Group 4")
                view.isHidden = true
            }
        }
    }
    
    func setTopView(){
        
        self.newTopView.isHidden = true
        self.topTitleImage.isHidden = false
        if EntourageManager.shared.myGroup?.status ?? "" == "active"{
            self.getAllYourFriends()
            currentGroup(group: EntourageManager.shared.myGroup! )
            self.newTopView.isHidden = false
            self.topTitleImage.isHidden = true
        }
        
    }
    
    func setRadarView(status:Bool){
        
        if status {
            radarDiskView.startAnimation()
            radarDiskView.numberOfCircles = 2
            radarDiskView.minimumCircleRadius = 70
            radarDiskView.paddingBetweenCircles = 60
            emptyOtherGroupMsg.isHidden = true
            serachFilterBtn.isHidden = true
        }else{
            radarDiskView.numberOfCircles = 0
            emptyOtherGroupMsg.isHidden = false
            serachFilterBtn.isHidden = false
            radarDiskView.stopAnimation()
        }
    }
    
    fileprivate func showSearchFilterPreview(){
        let vc = FilterDialogueVC.loadFilterDialogueVC {
            Utils.updateMyGroup = true
            self.updateView()
        }
        
        present(vc, animated: true, completion: nil)
    }
}



//MARK: - Actions
extension SwipeFriendsVC{
    
    @IBAction func tabToContinueBtn(_ sender:UIButton){
        self.demoView.isHidden = true
        continueFeedBackBtn(.soft)
        sender.tag == 222 ? cardSwipeAction(type: "Like") : cardSwipeAction(type: "unLike")
    }
    
    @IBAction func serachFilterBtn(_ sender:UIButton){
        if EntourageManager.shared.setting == nil{
            self.startAnimation()
            WebServicesManager.shared.getUserSettings { (response, error) in
                self.stopAnimation()
                
                if error == nil{
                    
                    self.showSearchFilterPreview()
                    
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }
            
        }else{
            self.showSearchFilterPreview()
        }
        
        
    }
    
    @IBAction func pressProfileBtn(_ sender: UIButton) {
        
        let activeProfileVC = self.loadActiveProfileVC {
            
            self.setupGUI()
        }
        
        Utils.transtion = true
        activeProfileVC.title = "Active Profile"
        self.navigationController?.pushViewController(activeProfileVC, animated: true)
        
    }
    
    @IBAction func pressMessageBtn(_ sender: UIButton) {
        
        let messagesVc = self.loadMessagingVC {
            self.setupGUI()
            
        }
        self.delegate = messagesVc
        Utils.transtion = true
        messagesVc.title = "Message"
        self.navigationController?.pushViewController(messagesVc, animated: true)
    }
    
    
    @IBAction func pressRadarDisk(_ sender:UIButton){
        sender.pulsate()
        radarDiskView.stopAnimation()
        radarDiskView.startAnimation()
        
    }
    
    @objc func pressAddFriendsBtn(){
        addGroupMember()
    }
    
    @objc func pressImportFriends(){
        
        let vc = SearchFriendsVC.loadSearchFriendsVC(flow: false) {
            
            if EntourageManager.shared.myGroup?.users.count ?? 0 > 1{
                self.getAllYourFriends()
            }else{
                self.getFriends()
            }
        }
        
        let VC = UINavigationController(rootViewController: vc)
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
    }
    
    func openImportFriendsVC(){
        
        let vc = SearchFriendsVC.loadSearchFriendsVC(flow: true) {
            
            if EntourageManager.shared.myGroup?.users.count ?? 0 > 1{
                self.getAllYourFriends()
            }else{
                self.getFriends()
            }
        }
        
        let VC = UINavigationController(rootViewController: vc)
        VC.modalPresentationStyle = .fullScreen
        present(VC, animated: true, completion: nil)
    }
    
    @objc func pressLinkBtn(){
        loadExtrenal(url: "https://www.entourage-app.com/faq.php")
    }
    
    @objc func pressShareUserNameBtn(){
        let ac = UIActivityViewController(activityItems: [user.user_name ?? ""], applicationActivities: nil)
        self.present(ac, animated: true)
    }
    
    @objc func pressGroupReportBtn(){

        currCardGroup = self.otherGroups[kolodaView.currentCardIndex]
        self.loadAlertReportVC(reportMembers: currCardGroup?.name ?? "" ,group: currCardGroup!){
            self.currCardGroup?.isReported = true
            self.cardSwipeAction(type: "unLike")
        }

    }
    
    @objc func pressFirstMemberBtn(){
        currCardGroup = self.otherGroups[kolodaView.currentCardIndex]
        
        if currCardGroup?.users.count ?? 0 > 0 {
            self.loadOtherUserProfileVC(user: currCardGroup!.users.last!, group: currCardGroup!) { (actionType) in
                self.cardSwipeAction(type: actionType)
            }
        }
    }
    
    @objc func pressSecondMemberBtn(){
        
        currCardGroup = self.otherGroups[kolodaView.currentCardIndex]
        if currCardGroup?.users.count ?? 0 > 0 {
            self.loadOtherUserProfileVC(user: currCardGroup!.users[0], group: currCardGroup!) { (actionType) in
                self.cardSwipeAction(type: actionType)
            }
        }
    }
    
    @objc func pressThirdMemberBtn(){
        currCardGroup = self.otherGroups[kolodaView.currentCardIndex]
        
        if currCardGroup?.users.count ?? 0 > 0 {
            
            let index = currCardGroup!.users.count == 4 ? 1 : 0
            self.loadOtherUserProfileVC(user: currCardGroup!.users[index], group: currCardGroup!) { (actionType) in
                self.cardSwipeAction(type: actionType)
            }
            
        }
    }
    
    @objc func pressFourMemberBtn(){
        currCardGroup = self.otherGroups[kolodaView.currentCardIndex]
        if currCardGroup?.users.count ?? 0 > 0 {
            let index = currCardGroup!.users.count == 4 ? 2 : 1
            self.loadOtherUserProfileVC(user: currCardGroup!.users[index], group: currCardGroup!) { (actionType) in
                self.cardSwipeAction(type: actionType)
            }
            
        }
    }
    
    
    func loadGroupActivityVC(friendsIds:[Int],listType:String){
        
        let vc2 = SelectGroupActivityVC.loadSelectGroupActivityVC(firendIds: friendsIds, update: false, listType: listType) { (groupStatus) in
            
            if groupStatus == true,EntourageManager.shared.myGroup?.status ?? "" == "active"{
                self.setTopView()
                self.updateView()
            }else{
                //self.addGroupMember()
                self.loadCustomeStatusVC(friendIds: friendsIds)
            }
            
        }
        
        var options = SheetOptions()
        options.pullBarHeight = 0
        options.shouldExtendBackground = false
        options.useFullScreenMode = false
        
        let sheetController = SheetViewController(controller: vc2, sizes: [.fixed(self.view.frame.height * 0.7 ),.fullscreen], options: options)
        
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
                
                self.setTopView()
                self.updateView()
                
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
        
        self.present(sheetController, animated: false, completion: nil)
        
    }
    
    private func cardsBtnEnablesCheck(group:Group){
        
        if group.status == "active"{
            
            if EntourageManager.shared.user.instantMatchAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.instantMatchAllow ?? 0 > 0{
                self.qucikMatch.isHidden = false
            }
            
            if EntourageManager.shared.user.spotLightAllow ?? 0 > 0 , EntourageManager.shared.myGroup?.spotLightAllow ?? 0 > 0 {
                self.spotLight.isHidden = false
            }else {
                
                if EntourageManager.shared.myGroup?.spotLightEnabled ?? false == false ,
                   EntourageManager.shared.user.spotLightAllow ?? 0 == 0{
                    
                    self.spotLight.isHidden = true
                    self.spotLightTimerLbl.text = ""
                    self.spotLightTimerView.isHidden = true
                    self.stopTimer()
                    
                }else  if EntourageManager.shared.myGroup?.spotLightEnabled ?? false == true{
                    self.timeRemaining = abs(group.spotLightRemainingTime ?? 1800)
                    self.totalTime = 1800//24 * 3600
                    self.spotLightTimerView.isHidden = false
                    self.startTimer()
                }
                
            }
            
        }else{
            self.qucikMatch.isHidden = true
            self.spotLight.isHidden = true
            self.spotLightTimerView.isHidden = true
            self.spotLightTimerLbl.text = ""
        }
        
    }
    
}


// MARK: - Group Api
extension SwipeFriendsVC{
    
    fileprivate func myGroup(completetion:@escaping ()->Void){
        
        WebServicesManager.shared.myGroup { (group, error) in
            if error == nil{
                
                guard let group = group as? Group else{
                    self.getFriends()
                    return
                }
                
                self.qucikMatch.isHidden = true
                self.spotLight.isHidden = true
                self.spotLightTimerView.isHidden = true
                
                self.upadteMessageIcon()
                self.setTopView()
                
                if group.status == "active"{
                    
                    self.cardsBtnEnablesCheck(group: group)
                    
                    if RecentUsers.getSavedRecentUsers()?.count ?? 0 == 0{
                        RecentUsers.saveRecentUsers(Users: group.users)
                    }
                    
                    self.getOtherGroups(pageIndex: self.pageIndex)
                    self.observLastMessage()
                    
                }else{
                    self.cardsBtnEnablesCheck(group: group)
                    self.getFriends()
                }
                
                completetion()
                
            }else{
                
                self.radarView.isHidden = true
                if error! == "Create or join a group first"{
                    self.getFriends()
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
                
                completetion()
            }
            
        }
    }
}




// MARK: - Card Left\Right Swiping Api
extension SwipeFriendsVC {
    
    fileprivate func unlikeTheGroup(){
        //        self.startAnimation()
        
        WebServicesManager.shared.unLikeTheGroup(groupId: "\(self.currCardGroup!.id)") { (group,error ) in
            // self.stopAnimation()
            if error == nil{
                self.undoBtn.isHidden = self.currCardGroup?.isReported ?? false ? true : false
            }else{
                
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    
    fileprivate func matchTheGroup(){
        
        
        WebServicesManager.shared.likeTheGroup(groupId: "\(self.currCardGroup!.id)") { (match,error ) in
            if error == nil{
                
                guard let match = match as? Match else{
                    return
                }
                self.undoBtn.isHidden = match.status == "match" ? true : false
                
                if match.status == "match"{
                    //self.playSound(name: "newmatch")
                    self.notificationFeedBackBtn(.success)
                    EntourageManager.shared.myMatchs.append(match)
                    self.loadGroupMatchedVC(group: match.matcher!, matchType: "") {
                        self.openChatVC(chatId: match.chat_id , group: match.matcher!) {
                            
                        }
                    }
                }
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
}


// MARK: - Fetch Cards
extension SwipeFriendsVC {
    
    func getOtherGroups(pageIndex:Int){
        
        if EntourageManager.shared.myGroup?.status == "active"{
            
            addFriendCardView.isHidden = true
            importFriendCardView.isHidden = true
            
            
            WebServicesManager.shared.findGroupsToMatch(page: pageIndex) { (response, error) in
                if error == nil{
                    
                    
                    guard let otherGroups = response as? OtherGroups else{
                        return
                    }
                    
                    EntourageManager.shared.otherGroups = otherGroups.groups
                    
                    self.cardsPagination = otherGroups.pagination
                    self.otherGroups = EntourageManager.shared.otherGroups
                    
                    self.friendListView.isHidden = false
                    
                    self.btnView.isHidden = self.otherGroups.count > 0 ? false : true
                    self.spotLightTimerView.isHidden = self.otherGroups.count > 0 ? self.spotLightTimerView.isHidden : true
                    
                    self.cardView.removeAll()
                    self.kolodaView.countOfVisibleCards = self.otherGroups.count > 1 ? 2 : 1
                    self.radarView.isHidden = self.otherGroups.count > 0 ? true : false
                    self.kolodaView.isHidden = self.otherGroups.count > 0 ? false : true
                    
                    self.setRadarView(status: self.otherGroups.count > 0 ? true : false)
                    
                    self.otherGroups.forEach({ (group) in
                        let view = self.setUpSwipeCardView(group: group)
                        self.cardView.append(view)
                    })
                    
                    self.kolodaView.resetCurrentCardIndex()
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }
        }else{
            setRadarView(status: true)
            self.addFriendCardView.isHidden = true
            self.importFriendCardView.isHidden = true
        }
        
        
    }
    
    
}


// MARK: - Get Friends Api
extension SwipeFriendsVC {
    
    fileprivate func getFriends(){
        
        WebServicesManager.shared.getFriendsList { (repsose, error) in
            if error == nil{
                self.radarView.isHidden = true
                self.friendListView.isHidden = false
                
                self.friends = EntourageManager.shared.FriendShips
                
                //temprary == 0 actual > 0
                if self.friends.count > 0{
                    self.setUpAddFriendView()
                }else{
                    self.setUpImportView()
                }
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
    fileprivate func getAllYourFriends(){
        
        WebServicesManager.shared.getFriendsList { (repsose, error) in
            if error == nil{
                self.friends = EntourageManager.shared.FriendShips
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
}

//MARK:- SpotLite Api Hook
extension SwipeFriendsVC{
    
    private func spotLiteApiCall(){
        WebServicesManager.shared.spotlight { (response, error) in
            if error == nil{
                self.myGroup {}
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
}

// MARK: - Add Chat Observer
extension SwipeFriendsVC{
    
    
    fileprivate func observLastMessage(){
        
        
        if lastMessageListner == nil{
            
            lastMessageListner = unReadMessageFirebaseService.matchListener()
        }
        
        lastMessageListner?.lastMesssageUpdates(limit: 100, completion: { (messageText, error) in
            if error != nil {
                self.showAlert(title: "Error", message: error!.localizedDescription)
            }else{
                self.delegate?.updateMatchList()
            }
            
        })
        
    }
    
}


// MARK: - KolodaViewDataSource
extension SwipeFriendsVC: KolodaViewDataSource {
    
    
    func kolodaNumberOfCards(_ koloda:KolodaView) -> Int {
        
        return cardView.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .default
        
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return cardView[index]
    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("swipeOverlyView", owner: self, options: nil)?[0] as? SwipeOverlayView
    }
    
    
}

// MARK: - KolodaViewDelegate
extension SwipeFriendsVC: KolodaViewDelegate {
    
    @IBAction func pressUndoBtn(_ sender: UIButton) {
        sender.pulsateBtn()
        cardSwipeAction(type: "undo")
    }
    
    @IBAction func pressNoBtn(_ sender: UIButton) {
        sender.pulsateBtn()
        if UserDefaults.standard.bool(forKey: firstUnLikeSwipe) == false{
            UserDefaults.standard.set(true, forKey: firstUnLikeSwipe)
            swipeDemo(type: "unLike")
        }else{
            cardSwipeAction(type: "unLike")
        }
    }
    
    @IBAction func pressDiamondBtn(_ sender: UIButton) {
        sender.pulsateBtn()
        cardSwipeAction(type: "spotLight")
    }
    
    @IBAction func pressMatchBtn(_ sender: UIButton) {
        sender.pulsateBtn()
        
        if UserDefaults.standard.bool(forKey: firstLikeSwipe) == false{
            UserDefaults.standard.set(true, forKey: firstLikeSwipe)
            swipeDemo(type: "Like")
        }else{
            cardSwipeAction(type: "Like")
        }
        
    }
    
    @IBAction func pressFireBtn(_ sender: UIButton) {
        sender.pulsateBtn()
        cardSwipeAction(type: "iMatch")
    }
    
    @IBAction func pressInviteNewMemberBtn(_ sender:UIButton){
        addGroupMember()
    }
    
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        if self.pageIndex <= self.cardsPagination.totalPages{
            
            self.pageIndex += 1
            EntourageManager.shared.otherGroups = []
            getOtherGroups(pageIndex: self.pageIndex)
            
        }
        
//        else{
//            self.pageIndex += 1
//            EntourageManager.shared.otherGroups = []
//            getOtherGroups(pageIndex: self.pageIndex)
//        }
        
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        
    }
    
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        return true
    }
    
    //kolodaShouldTransparentizeNextCard
    func kolodaShouldTransparentizeNextCard(_ koloda: KolodaView) -> Bool {
        return false
    }
    
    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
        
        if (direction.rawValue == "right") || (direction.rawValue ==  "up") ||
            (direction.rawValue == "topRight") || (direction.rawValue == "bottomRight"){
            
            if UserDefaults.standard.bool(forKey: firstLikeSwipe) == false{
                UserDefaults.standard.set(true, forKey: firstLikeSwipe)
                swipeDemo(type: "Like")
            }else{
                return true
            }
            
        }else{
            
            if UserDefaults.standard.bool(forKey: firstUnLikeSwipe) == false{
                UserDefaults.standard.set(true, forKey: firstUnLikeSwipe)
                swipeDemo(type: "unLike")
            }else{
                return true
            }
        }
        
        return false
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        
        if (direction.rawValue == "right") || (direction.rawValue ==  "up") ||
            (direction.rawValue == "topRight") || (direction.rawValue == "bottomRight"){
            
            currCardGroup = self.otherGroups[index]
            
            if instantMatch == true{
                
                instantMatch = false
                EntourageManager.shared.user.instantMatchAllow! -= 1
                EntourageManager.shared.myGroup?.instantMatchAllow! -= 1
                self.qucikMatch.isHidden = (EntourageManager.shared.user.instantMatchAllow ?? 0 == 0 && EntourageManager.shared.myGroup?.instantMatchAllow ?? 0 == 0) ? true : false
                
                self.instantMatch(groupId:"\(currCardGroup?.id ?? 0)" )
                
            }else{
                self.matchTheGroup()
            }
            
            
        }else{
            currCardGroup = self.otherGroups[index]
            self.unlikeTheGroup()
        }
        
        
        radarView.isHidden = index == self.otherGroups.count - 1 ? false : true
        kolodaView.isHidden = !self.radarView.isHidden
        btnView.isHidden = !self.radarView.isHidden
        spotLightTimerView.isHidden = index == self.otherGroups.count - 1 ? true : spotLightTimerView.isHidden
        spotLightTimerLbl.text = spotLightTimerView.isHidden == true ? "" : spotLightTimerLbl.text
        
    }
    
    private func kolodaSwipeThresholdRatioMargin(_ koloda: KolodaView) -> CGFloat {
        return CGFloat(Float(cardsSwipeLimit[cardSwipeLimitSelectedIndex]) ?? 0.4)
    }
    
}



// MARK: - PlaySound
extension SwipeFriendsVC{
    
    func playSound(name:String) {
        let path = Bundle.main.path(forResource: name, ofType : "wav")!
        let url = URL(fileURLWithPath : path)
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
            
        } catch {
            
            print ("There is an issue with this code!")
            
        }
        
    }
    
}

//MARK: - SpotLight ReNew Time Again
extension SwipeFriendsVC{
    
    private func startTimer(){
        
        if timer.isValid{
            timer.invalidate()
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerRunning), userInfo: nil, repeats: true)
        
    }
    
    private func stopTimer(){
        if timer.isValid{
            timer.invalidate()
        }
    }
    
    @objc func timerRunning() {
        
        var extraMinutes = "0"
        var extraSeconds = "0"
        //var extraHours = "0"

        timeRemaining -= 1
        
        let completionPercentage = abs( ( (Float(totalTime) - Float(timeRemaining))/Float(totalTime)) * 100 )
        spotLightTimerView.trackClr = UIColor.white
        spotLightTimerView.progressClr = UIColor("#6c62ff")
        spotLightTimerView.setProgressWithAnimation(duration: 0, value: completionPercentage / 100)
        //print("\(completionPercentage / 100)% done")
        
        let secondsLeft = Int(timeRemaining) % 60
        let minutesLeft = Int(timeRemaining) / 60 % 60
        //let hoursLeft = Int(timeRemaining / 3600)
        
        if secondsLeft > 9 {
            extraSeconds = ""
        }
        
        if minutesLeft > 9 {
            extraMinutes = ""
        }

//        if hoursLeft > 9 {
//            extraHours = ""
//        }

        
//        spotLightTimerLbl.text = "\(extraHours)\(hoursLeft):\(extraMinutes)\(minutesLeft):\(extraSeconds)\(secondsLeft)"
        spotLightTimerLbl.text = "\(extraMinutes)\(minutesLeft):\(extraSeconds)\(secondsLeft)"

        if timeRemaining == 0{
            self.spotLightTimerLbl.text = ""
            self.spotLight.isHidden = true
            self.spotLightTimerView.isHidden = true
            self.stopTimer()
            myGroup {}
        }
    }
    
}

//MARK: - Testing Things
extension SwipeFriendsVC{
    
    @IBAction func pressDragCardsLimit(sender:UIButton){
        setUpList(dataSource: cardsSwipeLimit, selectedList: [cardsSwipeLimit[cardSwipeLimitSelectedIndex]], relatedTF: emptyOtherGroupMsg, Title: "Cards Drag Limit")
    }
    
    private func setUpList(dataSource:[String],selectedList : [String],relatedTF:UILabel,Title:String){
        
        let selectionMenu = RSSelectionMenu(selectionStyle: .single, dataSource: dataSource, cellType: .basic ) { (cell, object, indexPath) in
            
            cell.textLabel?.text = object
            cell.textLabel?.font = UIFont(name: "Avenir-Medium", size: 20.0)!
            cell.tintColor = Colors.themeColor.value
        }
        
        selectionMenu.setSelectedItems(items: selectedList) { (selectedString , selectedIndex ,isSelected, selectedItems) in
            self.cardSwipeLimitSelectedIndex = selectedIndex
            //self.kolodaView.swipeLimit = Float(self.cardsSwipeLimit[selectedIndex]) ?? 0.4
            self.kolodaView.resetCurrentCardIndex()
        }
        
        selectionMenu.cellSelectionStyle = .checkbox
        selectionMenu.dismissAutomatically = false
        selectionMenu.show(style: .actionSheet(title: Title , action: "Done" , height: nil), from: self)
    }
}

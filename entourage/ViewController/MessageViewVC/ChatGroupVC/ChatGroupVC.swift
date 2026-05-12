//
//  ChatGroupVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/22/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import AwesomeEnum
import FirebaseFirestore
import AVFoundation
import NotificationCenter

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

class ChatGroupVC: MessagesViewController {
    
    //MARK: - IBOutLets
    @IBOutlet weak var nameLbl : UILabel!
    @IBOutlet weak var groupMmberNum : UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var emptyChatView: UIView!
    @IBOutlet weak var emptyChatmsgLbl: UILabel!
    @IBOutlet weak var emptyChatTitleLbl: UILabel!
    
    @IBOutlet weak var lbl1: UILabel!
    @IBOutlet weak var lbl2: UILabel!
    
    @IBOutlet weak var notificationViewHeight: NSLayoutConstraint!
    var layout : MessagesCollectionViewFlowLayout?
    
    //MARK:- Class Properties
    var callback : matchStatusUpdate!
    var player: AVAudioPlayer?
    
    struct ConversationDateFormatter {
        static let sectionFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM dd"
            //            formatter.dateStyle = DateFormatter.Style.medium
            //            formatter.timeStyle = .none
            formatter.doesRelativeDateFormatting = false
            return formatter
        }()
        
        static let timeFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .none
            formatter.timeStyle = .long
            return formatter
        }()
        
    }
    
    let outgoingAvatarOverlap: CGFloat = 8
    
    var User = EntourageManager.shared.user
    var personalChat = false
    var groupId:Int = 0
    var matchId:Int = 0
    var myGroup = EntourageManager.shared.myGroup!
    var group : Group!
    var usersTokens : [String] = []
    
    lazy var currUser : ChatUser = {
        return User.getChatUser(sideId: EntourageManager.shared.myGroup!.id )
    }()
    private var currentMode:ChatMessageEmoticon = .Neutral
    
    var messages : [MKMessage] = []
    var activeMemberFcmToken : [String] = []
    
    private var messagesBottomLabelsCache = Dictionary<String,Any?>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        self.title = "groupChat"
        
        
        topBarView.setTopNavBarShadow()
        self.view.addSubview(emptyChatView)
        self.view.addSubview(topBarView)
        
        
        self.updateView()
        
        
        //Layout adjustments
        layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.textMessageSizeCalculator.messageLabelFont = UIFont(name: "HelveticaNeue", size: 16)!
        
        //MessageKit setup
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        
        layout?.setMessageIncomingAccessoryViewSize(CGSize(width: 34, height: 34))
        layout?.setMessageIncomingAccessoryViewPadding(HorizontalEdgeInsets(left: 6, right: 0))
        layout?.setMessageIncomingAvatarSize(CGSize(width: 34, height: 34))
        layout?.setMessageIncomingAvatarPosition(AvatarPosition(horizontal: .natural, vertical: .messageBottom))
        let alignmentIncoming = LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 46 , bottom: 0, right: 0))
        
        layout?.setMessageIncomingMessageTopLabelAlignment(alignmentIncoming)
        
        layout?.setMessageOutgoingAccessoryViewSize(CGSize(width: 34, height: 34))
        
        layout?.setMessageOutgoingAccessoryViewPadding(HorizontalEdgeInsets(left: 0, right: 6))
        layout?.setMessageOutgoingAvatarSize(CGSize(width: 34, height: 34))
        
        layout?.setMessageOutgoingAvatarPosition(AvatarPosition(horizontal: .natural, vertical: .messageBottom))
        let alignmentOutgoing = LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 46))
        layout?.setMessageOutgoingMessageTopLabelAlignment(alignmentOutgoing)
        
        layout?.setAvatarLeadingTrailingPadding(2)
        //section inset bottom is Change due to message bottom padding
        layout?.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 2 , right: 8)
        
        //content insets
        messagesCollectionView.contentInset.top = 80
        messagesCollectionView.contentInset.bottom = 60
        
        
        // Input bar
        messageInputBar = InputBarAccessoryView()
        messageInputBar.delegate = self
        
        messageInputBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 60)
        messageInputBar.padding = UIEdgeInsets(top: 10, left: 13, bottom: 10, right: 8)
        messageInputBar.backgroundView.backgroundColor = UIColor.white
        
        messageInputBar.separatorLine.backgroundColor = UIColor("#cfd0d4")
        messageInputBar.separatorLine.alpha = 0
        
        //        messageInputBar.clipsToBounds = false
        messageInputBar.setChatScreenShadow()
        
        messageInputBar.inputTextView.delegate = self
        messageInputBar.inputTextView.returnKeyType = .send
        messageInputBar.inputTextView.autocorrectionType = .yes
        
        messageInputBar.isTranslucent = false
        
        messageInputBar.inputTextView.backgroundColor = .clear//UIColor("#F1F1F4")
        messageInputBar.inputTextView.layer.borderColor = .none//UIColor("#CFD0D4").cgColor
        //messageInputBar.inputTextView.tintColor = UIColor.black
        messageInputBar.inputTextView.textColor = UIColor.black
        messageInputBar.inputTextView.font = UIFont(name: "HelveticaNeue", size: 16)
        messageInputBar.inputTextView.layer.borderWidth = 0//0.5
        messageInputBar.inputTextView.autocorrectionType = .no
        messageInputBar.inputTextView.layer.cornerRadius = 0//18
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.spellCheckingType = .yes
        messageInputBar.inputTextView.autocorrectionType = .default
        messageInputBar.inputTextView.placeholderTextColor = UIColor("#c6c6c6")
        messageInputBar.inputTextView.placeholderLabel.font = UIFont(name: "Avenir-Book" , size: 16)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 8)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 17)
        messageInputBar.inputTextView.placeholder = "Type a message"
        
        //Right stack buttons - send button
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: 12)
        messageInputBar.sendButton.contentMode = .center
        messageInputBar.sendButton.setSize(CGSize(width: 38, height: 38), animated: true)
        messageInputBar.sendButton.setTitle("Send", for: .normal)
        messageInputBar.sendButton.titleLabel?.font = UIFont(name: "Avenir-Book", size: 16)
        messageInputBar.sendButton.setTitleColor(UIColor("#2ab7fe"), for: .normal)
        messageInputBar.sendButton.setTitleColor(UIColor("#d0d0d0"), for: .disabled)
        
        messageInputBar.sendButton.backgroundColor = .clear
        messageInputBar.middleContentViewPadding.right = 0
        messageInputBar.middleContentViewPadding.left = 0
        
        messageInputBar.setRightStackViewWidthConstant(to: 53, animated: true)
        messageInputBar.contentView.backgroundColor = UIColor("#f8f8f7")
        messageInputBar.contentView.layer.borderWidth = 0.5
        messageInputBar.contentView.layer.borderColor = UIColor("#CFD0D4").cgColor
        messageInputBar.contentView.layer.cornerRadius = 17.5
        
        showHornView()
        
        //reset layouts
        reloadInputViews()
        
        self.checkNotification()
        
        //scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnInputBarHeightChanged = false
        
        
        messageInputBar.inputTextView.isScrollEnabled = false
        
        getPreviousMsg{
            
            let chatId = self.personalChat == true ? self.groupId : self.matchId
                        
            
            if self.messages.count > 0{
                print ("document_\(chatId)----> ",self.messages.last?.innerMessage.messageData.text ?? "")
                
                self.updateLastMessageOnFireBase(senderid: self.messages.last?.sender.senderId ?? "", chat_id: chatId, lastReadCounter: self.messages.count, message: self.messages.last?.innerMessage.messageData.text ?? "", createdAt:self.messages.last?.sentDate ?? Date())
            }


        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.chatRoom = true
        Utils.chatVC = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.changeUserChatStatus(status: true) {
            print("-----> Chnage Status to Active. \n")
        }
    }
    
    func updateView(){
        
        if personalChat == true{
            myGroup = EntourageManager.shared.myGroup!
            group = EntourageManager.shared.myGroup!
        }else{
            
            myGroup = EntourageManager.shared.myGroup!
            updateMatchGroup(myGroup: myGroup, matchGroup: group)

        }
        
        setUpTopBar()
    }
    
    private func updateMatchGroup(myGroup:Group,matchGroup:Group){
        myGroup.users.forEach { (user) in
            if let matchUserIndex = matchGroup.users.lastIndex(where: {$0.id == user.id}){
                
                group.users.remove(at: matchUserIndex)
                if let matchGroupIndex = EntourageManager.shared.myMatchs.lastIndex(where: {$0.id == group.id}){
                    if group.users.count >= 2{ //if remaining User More than 2 or equal to 2
                        EntourageManager.shared.myMatchs[matchGroupIndex].matcher = group
                        setUpTopBar()
                    }else{ //if remaining User is 1
                        self.dismissChatRoom(dismissStatus: true)
                    }
                }
            }
            
        }
    }
    
    
    //MARK: - get All Msg
    private func getPreviousMsg(completion:@escaping ()->Void){
        
        chatListener!.subscribeForUpdates(limit: 5000 , added: { (ChatMessages) in
            
            ChatMessages.forEach({ (message) in
                
                let mkMessage = MKMessage(message:message)
                
                if self.isFromAnyGroup(message: mkMessage) == true{
                    self.messages.append(mkMessage)
                }else{
                    
                    //delete the unKown User msgs.
                    chatListener!.delete(docId: message.id) { (error) in
                        if error != nil{
                            print("\(message.id) -> ", error?.localizedDescription ?? "")
                        }else{
                            print("Completed")
                        }
                    }
                    
                }
                
                
            })
            
            self.emptyChatView.isHidden = self.messages.count == 0 ? false : true
            
            self.messagesCollectionView.reloadData()
            let indexPath = IndexPath(row: 0 , section: self.messages.count - 1)
            self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
            
            let chatRoomId = self.personalChat == true ? "\(self.groupId)" : "Match_\(self.matchId)"
            
            if Utils.appOpenForNotification == true{
                saveUnReadMsg(value: 0  , id: chatRoomId)
            }
            
            completion()
            
        })
        
        
        
    }
    
    func changeUserChatStatus(status:Bool,completion:@escaping ()->Void){
        
        
        let activeMmber = ActiveMember(senderId: currUser.id, status: status)
        
        activeMemberListner?.addAcvtiveDoc(docId: "\(currUser.firstName ?? "")_\(currUser.id)" , element: activeMmber , completion: { (member, error) in
            if error != nil{
                print(error?.localizedDescription ?? "")
            }else{
                completion()
            }
        })
    }
    
    private func getAllChatMember(callback:@escaping ([String])->Void){
        
        var myChatMembers : [User] = []
        
        myChatMembers = myGroup.users.filter({$0.id != Int(currUser.id) ?? 0 })
        
        if personalChat == false{
            myChatMembers += group.users
        }
        
        activeMemberListner?.fetchAllDocuments(personalChat: personalChat,added: { (activeMembers) in
            
            activeMembers.forEach({ (activeMember) in
                if activeMember.Active_Status == false{
                    
                    if let user = myChatMembers.first(where: {$0.id == Int(activeMember.SenderId) ?? 0}){
                        
                        //TODO: - Apend FCM Tokem of Member
                        if let token = user.fcm_tokens{
                            self.usersTokens.append(contentsOf: token)
                        }
                    }
                }
                
            })
            
            callback(self.usersTokens)
        })
        
        
    }
    
    fileprivate func checkNotification(){
        
        self.notificationViewHeight.constant = 0
        self.lbl1.text = "See when they respond"
        self.lbl2.text = "Enable push notifications"
        
        Utils.checkNotificationAuthorizationStatus { (status,value)  in
            if status == false{
                
                DispatchQueue.main.async {
                    self.messagesCollectionView.contentInset.top = 130
                    self.notificationViewHeight.constant = 56
                }
                
            }else{
                
                DispatchQueue.main.async {
                    
                    self.notificationViewHeight.constant = 0
                    self.lbl1.text = ""
                    self.lbl2.text = ""
                    self.messagesCollectionView.contentInset.top = 80
                    
                }
            }
        }
        
    }
    
    fileprivate func setUpTopBar(){
        var images : [String] = []
        
        if personalChat == true{
            self.emptyChatTitleLbl.text = "Group Chat"
            self.emptyChatmsgLbl.text = "Message your Group here, don’t worry nobody outside your group can see."
            self.nameLbl.text = group.myGroupName()
            self.groupMmberNum.text = "Group of \(myGroup.users.count)"
        }else{
            self.emptyChatTitleLbl.text = "Send a Message to Chat with your Group"
            self.emptyChatmsgLbl.text = "You've matched with \(group.matcherGroupName()), send them a message."
            self.groupMmberNum.text = "Group of \(group.users.count)"
            self.nameLbl.text = group.name ?? ""
        }
        
        
        let excpetSenderUser = group.users.filter({$0.id != User.id})
        
        excpetSenderUser.forEach({images.append($0.getPrimaryImageThumb())})
        
        for index in 0...2{
            
            let image = getImageViewWith(tag: (index)+5 , view: self.view)
            
            if index+1 <= images.count{
                
                if let url = URL(string:images[index]){
                    image.kf.indicatorType = .activity
                    //image.kf.setImage(with: url)
                    setupThumnail(url: url, IV: image)
                }
            }else{
                let view = getViewWith(tag: (index+1), view: self.view)
                view.isHidden = true
            }
        }
        
    }
    
    fileprivate func showHornView() {
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: true)
    }
    
    func dismissChatRoom(dismissStatus:Bool){
        
        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
        self.callback(dismissStatus)
        
        self.changeUserChatStatus(status: false) {
            
            Utils.chatRoom = false
            Utils.notificationInChatRoom = false
            activeMemberListner?.unsubscribe()
            chatListener?.unsubscribe()
            
        }
        
    }
    
    func dismissNotificationChatRoom(dismissStatus:Bool,completeion:@escaping ()->Void){
        
        self.callback(dismissStatus)
        self.dismiss(animated: false, completion: nil)
        self.navigationController?.popViewController(animated: false)
        completeion()

        self.changeUserChatStatus(status: false) {
            
            Utils.chatRoom = false
            Utils.notificationInChatRoom = false
            activeMemberListner?.unsubscribe()
            chatListener?.unsubscribe()
            
        }
        
    }
    
    
}


//MARK : - Actions
extension ChatGroupVC{
    
    @IBAction func pressBackBtn(_ sender: Any) {
        
        self.dismissChatRoom(dismissStatus: false)
    }
    
    @IBAction func pressMoreBtn(_ sender: Any) {
        
        if Utils.notificationInChatRoom == false{
            showSheetAlert()
        }
        
    }
    
    @IBAction func pressNotificationView(_ sender: Any) {
        
        Utils.notification = true
        let vc = NotificationsPermissionVC().loadNotificationsPermissionVC {
            self.checkNotification()
        }
        
        let nvc = UINavigationController(rootViewController: vc)
        nvc.modalPresentationStyle = .fullScreen
        self.present(nvc, animated: true, completion: nil)
        
        
    }
    
    fileprivate func showSheetAlert(){
        
        let alert = UIAlertController()
        
        if personalChat == true{
            
            alert.addAction(UIAlertAction(title: "Leave", style: .destructive, handler: { _ in
                
                let vc = LeaveGroupAlertVC.loadLeaveGroupAlertVC {
                    self.dismissChatRoom(dismissStatus: true)
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                
                
            }))
            
            
        }else{
            
            alert.addAction(UIAlertAction(title: "Unmatch", style: .destructive, handler: { _ in
                
                self.loadGroupUnMatchVC{
                    
                    self.dismissChatRoom(dismissStatus: true)
                    
                }
                
            }))
        }
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    fileprivate func itsMe(user:User?)->Bool{
        
        if user == nil{ return user!.id == EntourageManager.shared.user.id }
        else{ return true }
    
    }
        
    fileprivate func showUserProfile(senderId:Int){
        
        let alert = UIAlertController()
        var user : User?
        
        if self.personalChat == true{
            user = self.myGroup.users.last(where: {$0.id == senderId})
        }else{
            
            if self.myGroup.users.contains(where: {$0.id == senderId }){//is From SenderGroup
                user = self.myGroup.users.last(where: {$0.id == senderId})
            }else{//isFrom Chat Group
                user = self.group!.users.last(where: {$0.id == senderId})
            }
        }
        
        if !itsMe(user: user){
            
            alert.addAction(UIAlertAction(title: "Profile", style: .default, handler: { _ in
                self.loadUserProfileVC(user: user! , group: nil)
            }))
            
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        
        }
        
        
    }
    
    func showUserProfileOrReport(senderId:Int,reportMsgImage:UIImage){
        
        let alert = UIAlertController()
        var user : User?
        
        if self.personalChat == true{
            
             user = self.myGroup.users.last(where: {$0.id == senderId})

        }else{
            
            if self.myGroup.users.contains(where: {$0.id == senderId }){//is From SenderGroup
                 user = self.myGroup.users.last(where: {$0.id == senderId})
            }else{//isFrom Chat Group
                 user = self.group!.users.last(where: {$0.id == senderId})
            }
        }

          
        if !(user?.isBlocked ?? false) , itsMe(user: user){
            
            alert.addAction(UIAlertAction(title: "Block", style: .destructive, handler: { _ in
                self.loadAlertReportUserVC(user: user!, msgImage: reportMsgImage, report: false) {}
            }))
        }

        if itsMe(user: user){
            alert.addAction(UIAlertAction(title: "Report", style: .default, handler: { _ in
                self.loadAlertReportUserVC(user: user!, msgImage: reportMsgImage, report: true) {}
            }))
        
            alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)

        }
        
        
        
    }
    
    @objc func pressAvatarView(_ sender:UIButton){
        
        let senderId = sender.tag
        showUserProfile(senderId: senderId)
        
    }

}


// MARK: - MessagesDataSource
extension ChatGroupVC : MessagesDataSource {
    
    var currentSender: any MessageKit.SenderType {
        return Sender(senderId: currUser.id, displayName: currUser.displayName)
    }
    
        
    func isFromMe(message: MessageType)->Bool{
        return message.sender.senderId == currentSender.senderId
    }
    
    func isFromCurrentSender(message: MessageType) -> Bool {
        if personalChat == true{
            return isFromMe(message: message)
        }else{
            return isFromSenderGroup(message: message)
        }
    }
    
    func isFromSenderGroup(message: MessageType)->Bool{
        if let myMsg = self.messages.first(where: {$0.innerMessage.createdAt == message.sentDate.timeIntervalSince1970 && $0.sender.senderId == message.sender.senderId }){
           return myMsg.innerMessage.sender.groupId == myGroup.id ? true : false
        }

        let status = myGroup.users.contains(where: {$0.id == Int(message.sender.senderId) })
        return status
    }
    
    func isFromAnyGroup(message:MKMessage)->Bool{
        
        if personalChat == true{
            return myGroup.users.contains(where: {$0.id == Int(message.sender.senderId) })
        }else{
            if group.users.contains(where: {$0.id == Int(message.sender.senderId) }) == true{
                return true
            }else if myGroup.users.contains(where: {$0.id == Int(message.sender.senderId) }) == true{
                return true
            }
            
            return false
        }
        
    }
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return !isPreviousMessageSameDay(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return self.messages[indexPath.section].sender.senderId == self.messages[indexPath.section - 1].sender.senderId
    }
    
    /*actually in last 10 mins and not entire day*/
    func isPreviousMessageSameDay(at indexPath: IndexPath) -> Bool {
        
        guard indexPath.section - 1 >= 0 else { return false }
        let lastDate = self.messages[indexPath.section - 1].sentDate
        let nextDate = self.messages[indexPath.section].sentDate
        
        return nextDate.isInSameDayOf(date: lastDate )
        
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < self.messages.count else { return false }
        return self.messages[indexPath.section].sender.senderId == self.messages[indexPath.section + 1].sender.senderId
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.messages.count
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if isTimeLabelVisible(at: indexPath) {
            
            if ConversationDateFormatter.sectionFormatter.string(from: Date()) == ConversationDateFormatter.sectionFormatter.string(from: message.sentDate) {
                
                return NSAttributedString(string: "Today at \(dateToString(date: message.sentDate , formate: dateForamte.twelveHour.rawValue))", attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 11)!, NSAttributedString.Key.foregroundColor: UIColor("#666666")])
                
            } else {
                
                return NSAttributedString(string: ConversationDateFormatter.sectionFormatter.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 11)!, NSAttributedString.Key.foregroundColor: UIColor("#666666")])
            }
            
        }
        
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        //MARK: - BottomLbl (Read-Status)
        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        
        let type = message as! MKMessage
        let senderId = Int(type.sender.senderId)
        
        if type.senderAvatarURL.isEmpty{
            avatarView.initials = Utils.initials(fromName: type.sender.displayName)
        }else{
            if let url = URL(string: type.senderAvatarURL){
                avatarView.kf.indicatorType = .activity
                avatarView.kf.setImage(with: url )
            }
        }
        
        avatarView.isHidden = isNextMessageSameSender(at: indexPath)
        
        //Add my groupMember button Or MatchGroup member button
        if  avatarView.isHidden == false{
            
            let btn = UIButton(frame: CGRect(x: 0, y: 0, width: 34, height: 34))
            btn.backgroundColor = .clear
            btn.clipsToBounds = true
            btn.tag = senderId!
            avatarView.isUserInteractionEnabled = true
            avatarView.addSubview(btn)
            
            btn.addTarget(self, action: #selector(pressAvatarView), for: .touchUpInside)
        }
        
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        switch message.kind {
        case .photo(let photoItem):
            /// if we don't have a url, that means it's simply a pending message
            guard let _ = photoItem.url else {
                return
            }
            
        default:
            break
        }
    }
    
    
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        
        //get emtions label
        let emotionsIV = self.emotionsView(accessoryView, for: message, at: indexPath, in: messagesCollectionView)
        
        //message
        let type = message as! MKMessage
        
        //set image
        emotionsIV.text = type.innerMessage.emoticon.code
        
    }
    
    func emotionsView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView)->UILabel{
        
        var emotionView:UILabel
        
        //add it if not already added
        if accessoryView.subviews.isEmpty{
            let view = UILabel()
            accessoryView.addSubview(view)
            view.frame = accessoryView.bounds
            accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
            accessoryView.backgroundColor = Color.clear
            emotionView = view
        }else{
            emotionView = accessoryView.subviews.first as! UILabel
        }
        
        return emotionView
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if !isPreviousMessageSameSender(at: indexPath){//isNextMessageSameSender(at: indexPath){
            
            return NSAttributedString(
                string: message.sender.displayName,
                attributes: [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue", size: 12.0)! ,NSAttributedString.Key.foregroundColor : UIColor("#4E4E4E")]
            )
            
        }else{
            
            return NSAttributedString(
                string: "",
                attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1),NSAttributedString.Key.foregroundColor : UIColor("#4E4E4E")]
            )
            
        }
        
        
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        var bottomLabel : NSMutableAttributedString?
        //found in cache
        if let bottomLabel = self.messagesBottomLabelsCache[message.messageId] as? NSAttributedString{
            return bottomLabel
        }
        
        let date = message.sentDate.timeAgoSinceDate(message.sentDate, numericDates: true)
        
        
        let timeLabel = NSAttributedString(
            string: date,
            attributes: [NSAttributedString.Key.font:  UIFont(name: "Avenir-Book", size: 12.0)!,NSAttributedString.Key.foregroundColor : UIColor("#d2d2d2")]
        )
        
        let senderName = NSAttributedString(
            string: "\( message.sender.displayName) ",
            attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12.0)!,NSAttributedString.Key.foregroundColor : UIColor("#666666")]
        )
        
        let statusLabel = self.messageStatusAttributedText(for: message, at: indexPath)
        
        if personalChat == true{//My Group Chat
            
            //If last message from my side
            if message.sender.senderId == currentSender.senderId {
                if statusLabel?.string ?? "" == "" {
                    
                    let time = NSMutableAttributedString(attributedString:timeLabel)
                    bottomLabel = NSMutableAttributedString(attributedString:senderName)
                    bottomLabel?.append(time)
                    //   bottomLabel = NSMutableAttributedString(attributedString:timeLabel)
                }else{
                    bottomLabel = NSMutableAttributedString(attributedString:statusLabel!)
                }
                
            }else{
                
                let time = NSMutableAttributedString(attributedString:timeLabel)
                bottomLabel = NSMutableAttributedString(attributedString:senderName)
                bottomLabel?.append(time)
            }
            
        }else{
            // if message from MatchGroupMember
            if myGroup.users.contains(where: {$0.id == Int(message.sender.senderId) }) == false{
                
                let time = NSMutableAttributedString(attributedString:timeLabel)
                bottomLabel = NSMutableAttributedString(attributedString:senderName)
                bottomLabel?.append(time)
            }else{ // if message from MyGroup
                
                if message.sender.senderId == currentSender.senderId {
                    if statusLabel?.string ?? "" == "" {
                        
                        let time = NSMutableAttributedString(attributedString:timeLabel)
                        bottomLabel = NSMutableAttributedString(attributedString:senderName)
                        bottomLabel?.append(time)
                        
                    }else{
                        bottomLabel = NSMutableAttributedString(attributedString:statusLabel!)
                    }
                }else{
                    
                    let time = NSMutableAttributedString(attributedString:timeLabel)
                    bottomLabel = NSMutableAttributedString(attributedString:senderName)
                    bottomLabel?.append(time)
                    
                }
                
            }
            
        }
        
        //save in cache
        self.messagesBottomLabelsCache[message.messageId] = bottomLabel
        
        
        return bottomLabel
    }
    
    func messageStatusAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        //only check for my own messages
        guard message.sender.senderId == currentSender.senderId else{
            return NSMutableAttributedString(string: "",attributes: [:])
        }
        
        let myLastMessageIndex  = messages.lastIndex(where: {$0.sender.senderId == currUser.id}) ?? -1
        
        guard myLastMessageIndex == indexPath.section else {
            return NSMutableAttributedString(string: "",attributes: [:])
        }
        
        var statusString = "Delivered"
        
        statusString = self.messageReadStatusText(for: message, at: indexPath)!
        
        let statusLabel = NSMutableAttributedString(
            string: statusString,
            attributes: [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 12.0)!,NSAttributedString.Key.foregroundColor : UIColor("#d2d2d2")]
        )
        
        return statusLabel
    }
    
    
    func messageReadStatusText(for message: MessageType, at indexPath: IndexPath) -> String?{
        
        let statusString = "Delivered"
        return statusString
    }
    
    
    
}

// MARK: - MessagesLayoutDelegate
extension ChatGroupVC : MessagesLayoutDelegate{
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if isTimeLabelVisible(at: indexPath){
            return 47
        }
        return 0
    }
    
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        
        if isNextMessageSameSender(at: indexPath){
            return 0
        }else{
            return (16)
        }
        
        
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        
        
        if !isPreviousMessageSameSender(at: indexPath) {//isNextMessageSameSender(at: indexPath) {
            return (0) //+ outgoingAvatarOverlap
        }else{
            return 0
        }
        
        
    }
    
    func messagePadding(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIEdgeInsets {
        return isFromCurrentSender(message: message)
            ? UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 4)
            : UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 30)
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: messagesCollectionView.bounds.width, height: 14)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 200
    }
    
}


// MARK: - MessagesDisplayDelegate
extension ChatGroupVC : MessagesDisplayDelegate{
    
    
    // MARK: - Text Messages
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    // MARK: - All Messages
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor("#2AB7FE") : UIColor("#E9E9EB")
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
                
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            
            //First Msg of Same Sender MsgGrouping
            if !isPreviousMessageSameSender(at: indexPath) {
                return .custom { view in
                    view.roundCorners(topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4)
                }
            }
            
            if !isNextMessageSameSender(at: indexPath), isPreviousMessageSameSender(at: indexPath){
                return .custom { view in
                    view.roundCorners(topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 4)
                }
                
            }
            
            //All Msg Btw First & Last Msg of Same Sender MsgGrouping
            if isPreviousMessageSameSender(at: indexPath) , isNextMessageSameSender(at: indexPath){
                return .custom { view in
                    view.roundCorners(topLeft: 16, topRight: 4, bottomLeft: 16, bottomRight: 4)
                }
            }
            
            //Last Msg of Same Sender Single Msg Group
            if !isPreviousMessageSameSender(at: indexPath) , !isNextMessageSameSender(at: indexPath) {
                return .custom { view in
                    view.roundCorners(topLeft: 16, topRight: 16, bottomLeft: 16, bottomRight: 4)
                }
            }
            
            
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            
            //First Msg of Same Sender MsgGrouping
            if !isPreviousMessageSameSender(at: indexPath) {
                return .custom { view in
                    view.roundCorners(topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16)
                }
                
            }
            
            if !isNextMessageSameSender(at: indexPath), isPreviousMessageSameSender(at: indexPath){
                return .custom { view in
                    view.roundCorners(topLeft: 4, topRight: 16, bottomLeft: 4, bottomRight: 16)
                }
                
            }
            
            //All Msg Btw First & Last Msg of Same Sender MsgGrouping
            if isPreviousMessageSameSender(at: indexPath) , isNextMessageSameSender(at: indexPath) {
                return .custom { view in
                    view.roundCorners(topLeft: 4, topRight: 16, bottomLeft: 4, bottomRight: 16)
                }
            }
            
            //Last Msg of Same Sender Single Msg Group
            if !isPreviousMessageSameSender(at: indexPath) , !isNextMessageSameSender(at: indexPath) {
                return .custom { view in
                    view.roundCorners(topLeft: 16, topRight: 16, bottomLeft: 4, bottomRight: 16)
                }
            }
            
            
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
        
    }
    
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType]{
        return [DetectorType.url, .address, .phoneNumber]
    }
}


// MARK: - InputBarAccessoryViewDelegate
extension ChatGroupVC : InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        
        //TODO - add local message directly
        //TODO - combin send mesage into one method
        
        //showHornView()
        
        DispatchQueue.main.async {
            inputBar.inputTextView.text = ""
            self.messageInputBar.inputTextView.text = ""
        }
        
        
        if inputBar.inputTextView.images.count > 0 {
            let photo = inputBar.inputTextView.images[0]
            let text = inputBar.inputTextView.text!
            
            
            var message = ChatMessage(photo: photo, sender: currUser , emoticon: self.currentMode)
            message.messageData.text = text
            self.sendMessage(message: message)
            return
        } else if inputBar.inputTextView.text.count > 0 {
            let text = inputBar.inputTextView.text!
            
            var message = ChatMessage(text: text, sender: currUser, emoticon: self.currentMode)
            message.messageData.text = text
            self.sendMessage(message: message)
            return
        }
        
        //blank emoticon message
        self.sendEmoticonMessage(emoticon: self.currentMode)
        
    }
    
    
    private func sendEmoticonMessage(emoticon:ChatMessageEmoticon){
        
        //blank emoticon message
        if self.currentMode != .Neutral {
            
            let message = ChatMessage(text: "", sender: currUser , emoticon: self.currentMode)
            self.sendMessage(message: message)
        }
        
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        
    }
    
    private func sendMessageWithImage(message:String, photo:UIImage) {
        
    }
    
    private func sendMessage(message:ChatMessage) {
        
        var newMessage = message
        let messageId = chatListener!.autoDocumentId().documentID
        newMessage.id = messageId
        
        _ = messages.count
        
        chatListener?.addChatMessage(docId: messageId, element: newMessage) { (message, error) in
            if error != nil{
                print("SendMessageError -> ",error!,"\n")
            }else{
                                
                let id = self.personalChat == true ? self.groupId : self.matchId
                
                self.saveDataLocaly(senderId: message.sender.id, chat_id: id, message:message.messageData.text)
                
                self.sendUnActiveMemberMessage(Message: message.messageData.text )
                
            }
        }
        
    }
    
    func sendUnActiveMemberMessage(Message:String){
        
        let id = self.personalChat == true ? self.groupId : self.matchId
        
        self.getAllChatMember { (tokens) in
            
            if tokens.isEmpty == false{
                self.sendNotification(msg: Message , id: id , fcm_tokens: tokens)
            }
        }
        
    }
    
    fileprivate func reloadAndScrollToBottom() {
        self.messagesCollectionView.reloadData()
        let section = self.messages.count - 1
        if section >= 0 {
            let indexPath = IndexPath(item: 0, section: section)
            self.messagesCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        }
    }
    
    private func saveDataLocaly(senderId:String, chat_id:Int, message:String){
        
        let chatRoomId = personalChat == true ? "\(chat_id)" : "Match_\(chat_id)"
        
        //user Save his Last Msg
        saveMyMsg(message: message , id: chatRoomId)
        //user Save his Group / Match Last Msg
        saveLastMsg(message: message, id: chatRoomId)
        
        saveLastSender(id: Int(senderId) ?? 0, key: chatRoomId)
        
    }
    
    //MARK: - LastMsg on fireBase
    private func updateLastMessageOnFireBase(senderid:String, chat_id:Int, lastReadCounter:Int , message:String,createdAt:Date){
        
        let chatRoomId = personalChat == true ? "\(chat_id)" : "Match_\(chat_id)"
        
        lastMessageListner?.updateLastMessage(docId: chatRoomId, userReadCounter: lastReadCounter , element: self.group.lastMessageObject(message: message, senderId: Int(senderid) ?? 0, readCounter: lastReadCounter), createdAt: createdAt , completion: { (lastMessage, error) in
            if error != nil{
                print("Last_Message Not Sent on fireBase -> ",error!,"\n")
            }else{
                print("Last_Message Sent on fireBase -> ")
                
            }
        })
        
    }
    
    private func sendNotification(msg:String , id:Int,fcm_tokens:[String]){
        
        WebServicesManager.shared.sendLastMessageNotification(lastMsg: msg , matchId: id ,  fcmToken: fcm_tokens, msgGroup: group.id) { (response, error) in
            self.usersTokens.removeAll()
            if error == nil{
                print("Msg Notifocation Send")
            }else{
                print("Msg Notifocation Not Send ", error!,"\n")
            }
            
        }
    }
    
}

//MARK: - UITextViewDelegate
extension ChatGroupVC : UITextViewDelegate{
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            
            if messageInputBar.inputTextView.text.count > 0 {
                let text = messageInputBar.inputTextView.text!
                
                var message = ChatMessage(text: text, sender: currUser , emoticon: self.currentMode)
                message.messageData.text = text
                textView.text = ""
                self.sendMessage(message: message)
                
            }
            return false
        }
        return true
    }
    
}


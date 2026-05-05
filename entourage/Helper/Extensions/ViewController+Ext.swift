//
//  ViewController+Ext.swift
//  Hello.
//
//  Created by Furqan Ahmad on 02/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import UIKit

extension BaseVC {
    
    func useBackButton(image: UIImage?) {
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(popToBackViewController(sender:)))
    }
    
    @objc func popToBackViewController(sender: UIBarButtonItem) {
        sender.isEnabled = false
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    func takeImage(imagePicker:UIImagePickerController){
                
        let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera(imagePicker: imagePicker)
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary(imagePicker: imagePicker)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    func openCamera(imagePicker:UIImagePickerController)
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.cameraCaptureMode = .photo

            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary(imagePicker:UIImagePickerController)
    {
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK :-  GroupInvite Notification Method
    func ShowGroupInvite(groupId:Int){
        
        WebServicesManager.shared.getUser { (user, error) in
            if error == nil{
                
                
                let vc = GroupInviteVC.groupInviteVC(groupInvitedId: groupId  ){ (status) in
                    if status{
                        Utils.updateMyGroup = true
                        lastMessageListner?.unsubscribe()
                        self.loadSwipeFriendsVC()
                    }
                }
                
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true, completion: nil)
                
            }
            
        }
        
        
    }
    
    //MARK :-  GroupLeft , GroupInviteAccepted , GroupInviteDeclined  Notification Method
    func updateGroupObject(type:String){
        
        
        WebServicesManager.shared.myGroup { (myGroup, error) in
            
            guard let myGroup = myGroup as? Group else{
                return
            }
            
            EntourageManager.shared.myGroup = myGroup
            
            if Utils.chatRoom == true{
                //In ChatRoom
                if myGroup.status != "active",type == "GroupLeft"{
                    //remove Group
                    
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    UserDefaults.standard.synchronize()
                    
                    EntourageManager.shared.user.saveToken()
                    resetAllUnReadMsg()
                    EntourageManager.shared.myGroup = nil
                    
                    lastMessageListner?.unsubscribe()
                    activeMemberListner?.unsubscribe()
                    chatListener?.unsubscribe()
                    
                    Utils.chatRoom = false
                    Utils.notificationInChatRoom = false
                    
                    Utils.chatVC?.loadSwipeFriendsVC()
                    
                }else{
                    
                    Utils.updateMyGroup = true
                    Utils.chatVC?.updateView()
                }
                
            }else{
                
                //Out Side of Chat Room
                if myGroup.status != "active",type == "GroupLeft"{
                    //remove Group
                    
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    UserDefaults.standard.synchronize()
                    
                    lastMessageListner?.unsubscribe()
                    activeMemberListner?.unsubscribe()
                    chatListener?.unsubscribe()
                    
                    EntourageManager.shared.user.saveToken()
                    resetAllUnReadMsg()
                    EntourageManager.shared.myGroup = nil
                    
                    Utils.currVC?.loadSwipeFriendsVC()
                    
                }else{
                    
                    //if currentScreen is Card Screen
                    Utils.updateMyGroup = true
                    if Utils.currVC?.title ?? "" == "Message"{
                        Utils.currVC?.setupGUI()
                    }else{
                        Utils.currVC?.updateGUI()
                    }
                    
                }
                
            }
        }
        
    }
    
    //MARK :-  Message Notification Method
    func openChatVC(chatId:Int,group:Group,completeion:@escaping()->Void){
        
        Utils.notificationInChatRoom = true
        
        let chatRoomId = chatId == 0 ? "\(group.id)" : "Match_\(chatId)"
        
        if chatId == 0{
            resetUnReadMsg(id: chatRoomId)
            Utils.mainVC?.upadteMessageIcon()
        }else{
            decrementUnReadMsgCounter(value: getUnReadMsg(id: chatRoomId) )
            resetUnReadMsg(id: chatRoomId )
            
            Utils.mainVC?.upadteMessageIcon()
        }
        
        
//        activeMemberListner?.unsubscribe()
//        chatListener?.unsubscribe()
//        chatListener = nil
        //ChatMessage FireStore Referernce
        chatListener = MessageFirebaseService.createListener(id: chatRoomId)
        
        //ChatMember Avtive Status FireStore Referernce
        activeMemberListner = ActiveMemberFireBaseService.creatActiveListner(id:chatRoomId )
        
        self.loadChatGroupVC(matchId: chatId, group: group ) { (updateStatus) in
            
        }
        
        completeion()
    }
    
    //MARK:- Matches
    func upadteMatchGroup(match_Id:Int ){
        
        if Utils.chatRoom == true{
            if Utils.chatVC?.matchId == match_Id{
                Utils.chatVC?.dismissChatRoom(dismissStatus: true)
            }
        }else if Utils.currVC?.title ?? "" == "Message"{
            Utils.currVC?.setupGUI()
        }
        
    }
    
    func matchInvite(matchId:Int,completeion:@escaping()->Void){
        
        WebServicesManager.shared.matchList { (list, error) in
            
            if error == nil{
                if let match = EntourageManager.shared.myMatchs.last(where: {$0.matcher?.id == matchId}){
                    Utils.currVC?.loadGroupMatchedVC(group: match.matcher!, matchType: "") {
                        self.openChatVC(chatId: match.chat_id , group: match.matcher!) {
                            
                        }
                    }
                    completeion()
                }else{
                    completeion()
                }
                
            }else{
                Utils.currVC?.showAlert(title: "Error", message:error!)
                completeion()
            }
        }
    }
    
    
    //MARK: - UPdate Group Status
    func updateGroupStatus(){
        
        WebServicesManager.shared.myGroup { (myGroup, error) in
            
            guard let _ = myGroup as? Group else{
                return
            }
            
            if Utils.currVC?.title == "Active Profile"{
                Utils.currVC?.updateGUI()
            }else{
                Utils.currVC?.updateGUI()
            }
            
        }
    }
    
    //MARK: - FriendRequest Deeplink in App
    func FriendShipNotification(){
        if Utils.currVC?.title == "Add Friends"{
            
            if let vc = Utils.currVC as? SearchFriendsVC{
                vc.follow = true
                Utils.currVC?.setupGUI()
            }else{
                Utils.currVC?.setupGUI()
            }
            
        }else{
            
            let vc = SearchFriendsVC.loadSearchFriendsVC(flow: true) {
                
                WebServicesManager.shared.getFriendsList { (repsose, error) in
                    if error == nil{
                        Utils.currVC?.setupGUI()
                    }else{
                        Utils.currVC?.showAlert(title: "Error", message: error!)
                    }
                }
                
            }
            let VC = UINavigationController(rootViewController: vc)
            VC.modalPresentationStyle = .fullScreen
            Utils.currVC?.present(VC, animated: true, completion: nil)

        }
    }
    
    //MARK: - Upadte GroupMember Profile Pic
    func updationOfProfilePic(){
     
        WebServicesManager.shared.myGroup { (myGroup, error) in
            
            guard let _ = myGroup as? Group else{
                return
            }
            
            if Utils.chatRoom == true{
                Utils.chatVC?.updateView()
            }else if Utils.currVC?.title == "Add Friends"{
                    Utils.currVC?.setupGUI()
            }else{
                Utils.currVC?.updateGUI()
            }
            
        }

    }

    
}

//MARK: - SelectGroupActivityVC
extension SelectGroupActivityVC{
 
    func setUpSelective(tab:Int){
        
        for index in 1...3{
            
            let barView = getViewWith(tag: index, view: self.view)
            let titleLbl = getLabelWith(tag: index+3, view: self.view)
            
            if (tab == index && tab == 1) || (tab == index && tab == 2){
                
                titleLbl.textColor = UIColor.black
                titleLbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                barView.isHidden = false
            }else if tab == index , tab == 3 {
                titleLbl.textColor = UIColor("#6E5CFF")
                titleLbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                barView.isHidden = false
            }else if index == 3{
                titleLbl.textColor = UIColor("#6E5CFF")
                titleLbl.font = UIFont(name: "Avenir-Book", size: 17)
                barView.isHidden = true
            }else{
                titleLbl.textColor = UIColor.lightGray
                titleLbl.font = UIFont(name: "Avenir-Book", size: 17)
                barView.isHidden = true
            }
            
        }
        
    }
}

extension CustomStatusVC{
    
    func setUpSelective(tab:Int){
        
        for index in 1...3{
            
            let barView = getViewWith(tag: index*100, view: self.view)
            let titleLbl = getLabelWith(tag: (index+3)*100, view: self.view)
            
            if (tab == index && tab == 1) || (tab == index && tab == 2){
                
                titleLbl.textColor = UIColor.black
                titleLbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                barView.isHidden = false
            
            }else if tab == index , tab == 3 {
                
                titleLbl.textColor = UIColor("#6E5CFF")
                titleLbl.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                barView.isHidden = false
            
            }else if index == 3{
                
                titleLbl.textColor = UIColor("#6E5CFF")
                titleLbl.font = UIFont(name: "Avenir-Book", size: 17)
                barView.isHidden = true
            
            }else{
                titleLbl.textColor = UIColor.lightGray
                titleLbl.font = UIFont(name: "Avenir-Book", size: 17)
                barView.isHidden = true
            }
            
        }
        
    }
}

//MARK: - SelectGroupActivityVC
extension SearchFriendsVC{
    
    func setUpSelectiveTabBtn(tab:Int,btn1: UIButton,btn2:UIButton,btn3:UIButton){
        
            if tab == 1{
                btn1.setTitleColor(UIColor.black, for: .normal)
                btn1.titleLabel?.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                
                btn2.setTitleColor(UIColor("#878F96"), for: .normal)
                btn2.titleLabel?.font = UIFont(name: "Avenir-Book", size: 17)

                btn3.setTitleColor(UIColor("#878F96"), for: .normal)
                btn3.titleLabel?.font = UIFont(name: "Avenir-Book", size: 17)

            }else if tab == 2{
                btn2.setTitleColor(UIColor.black, for: .normal)
                btn2.titleLabel?.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                
                btn1.setTitleColor(UIColor("#878F96"), for: .normal)
                btn1.titleLabel?.font = UIFont(name: "Avenir-Book", size: 17)

                btn3.setTitleColor(UIColor("#878F96"), for: .normal)
                btn3.titleLabel?.font = UIFont(name: "Avenir-Book", size: 17)
            }else if tab == 3{
                
                btn3.setTitleColor(UIColor.black, for: .normal)
                btn3.titleLabel?.font = UIFont(name: "Avenir-BlackOblique", size: 17)
                
                btn1.setTitleColor(UIColor("#878F96"), for: .normal)
                btn1.titleLabel?.font = UIFont(name: "Avenir-Book", size: 17)

                btn2.setTitleColor(UIColor("#878F96"), for: .normal)
                btn2.titleLabel?.font = UIFont(name: "Avenir-Book", size: 17)

        }

    }

}

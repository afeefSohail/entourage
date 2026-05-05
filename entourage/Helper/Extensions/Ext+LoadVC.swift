//
//  Ext+LoadVC.swift
//  Hello.
//
//  Created by Furqan Ahmad on 02/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

//MARK: - Loading Controllers
extension UIViewController {
    
    // OnBoarding Controllers
     func loadTutorialVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let tutorialVC = storyboard.instantiateViewController(withIdentifier: "TutorialVC") as! TutorialVC
     
        self.navigationController?.show(tutorialVC, sender: nil)
    }

    //MARK: - PhoneNumVerifyVC
    func loadPhoneNumVerifyVC(){
        let loginVC = UIStoryboard(name: "onBoarding", bundle: nil).instantiateViewController(identifier: "PhoneNumVerifyVC") as! PhoneNumVerifyVC
        
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true, completion: nil)
    }

    
    //MARK: - VerifyPinVC
    func loadVerifyPinVC(phoneNumber:String){
        
        let verifyPinVC = UIStoryboard(name: "onBoarding", bundle: nil).instantiateViewController(identifier: "VerifyPinVC") as! VerifyPinVC
        
        verifyPinVC.modalPresentationStyle = .fullScreen
        verifyPinVC.userPhone = phoneNumber
        self.show(verifyPinVC, sender: nil)
    }

    func loadGenderSelectedVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let genderSelectionVC = storyboard.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        
       UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController:genderSelectionVC )
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
    func loadProfilePictureVC(root:Bool) {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let profilePictureVC = storyboard.instantiateViewController(withIdentifier: "ProfilePictureVC") as! ProfilePictureVC
        
        if root == true{
            UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController:profilePictureVC)
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            profilePictureVC.setUpNavigationBar()

        }else{
            self.navigationController?.show(profilePictureVC, sender: nil)
        }
    }
    
    func loadCreateUserNameVC(root:Bool) {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let createUserNameVC = storyboard.instantiateViewController(withIdentifier: "CreateUserNameVC") as! CreateUserNameVC
        
        if root == true{
            UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController:createUserNameVC )
            UIApplication.shared.keyWindow?.makeKeyAndVisible()
            
            createUserNameVC.setUpNavigationBar()

        }else{
            self.navigationController?.show(createUserNameVC, sender: nil)
        }
    }

    func loadContactPermissionVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let contactPermissionVC = storyboard.instantiateViewController(withIdentifier: "ContactPermissionVC") as! ContactPermissionVC
        
        UIApplication.shared.keyWindow?.rootViewController = UINavigationController(rootViewController:contactPermissionVC )
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }

    func loadAddFirstNameVC(vcType:Bool) {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let addFirstNameVC = storyboard.instantiateViewController(withIdentifier: "AddFirstNameVC") as! AddFirstNameVC
        addFirstNameVC.vcType = vcType
     
        self.navigationController?.show(addFirstNameVC, sender: nil)
    }

    func loadAddBirthdayDateVC() {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let addBirthdayDateVC = storyboard.instantiateViewController(withIdentifier: "AddBirthdayDateVC") as! AddBirthdayDateVC
        
        self.navigationController?.show(addBirthdayDateVC, sender: nil)
    }
    
    func loadAddFriendsVC(){
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let addFriendsVC = storyboard.instantiateViewController(withIdentifier: "AddFriendsVC") as! AddFriendsVC

        self.navigationController?.show(addFriendsVC, sender: nil)
        
    }

    //MARK: - Alerts
    func loadSMSDialogueVC(callback:@escaping PressOkay){
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let smsDialogueVC = storyboard.instantiateViewController(withIdentifier: "SMSDialogueVC") as! SMSDialogueVC
        
        smsDialogueVC.callback = callback
        smsDialogueVC.modalPresentationStyle = .overCurrentContext
        self.present(smsDialogueVC, animated: true, completion: nil)

    }

    func loadBlockAlertVC(user:User,callback:@escaping blockOrUnBlock){
        let alertVC: AlertVC = UIStoryboard.init(name: "Alerts", bundle: nil).instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        
        alertVC.callback = callback
        alertVC.user = user
        alertVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(alertVC, animated: true, completion: nil)
    }
    

    func loadGroupUnMatchVC(callback:@escaping PressOkay){
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let groupUnMatchVC = storyboard.instantiateViewController(withIdentifier: "GroupUnMatchVC") as! GroupUnMatchVC
        
        groupUnMatchVC.callback = callback
        groupUnMatchVC.modalPresentationStyle = .overCurrentContext
        self.present(groupUnMatchVC, animated: true, completion: nil)
    }

    func loadAlertReportVC(reportMembers:String,group:Group,callback:@escaping PressOkay){
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let alertReportVC = storyboard.instantiateViewController(withIdentifier: "AlertReportVC") as! AlertReportVC
        
        alertReportVC.reportedUserName = reportMembers
        alertReportVC.reportedGroup = group
        alertReportVC.callback = callback
        
        alertReportVC.modalPresentationStyle = .overCurrentContext
        self.present(alertReportVC, animated: true, completion: nil)
    }

    func loadAlertReportUserVC(user:User,msgImage:UIImage,report:Bool,callback:@escaping PressOkay){
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let alertReportUserVC = storyboard.instantiateViewController(withIdentifier: "AlertReportUserVC") as! AlertReportUserVC

        alertReportUserVC.report = report
        alertReportUserVC.user = user
        alertReportUserVC.msgImage = msgImage
        alertReportUserVC.callback = callback
        
        alertReportUserVC.modalPresentationStyle = .overCurrentContext
        self.present(alertReportUserVC, animated: true, completion: nil)
    }
    
    func loadPremiumVC(){
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let premiumVC = storyboard.instantiateViewController(withIdentifier: "PremiumVC") as! PremiumVC
        
        premiumVC.modalPresentationStyle = .overCurrentContext
        self.present(premiumVC, animated: true, completion: nil)
    }

    //MARK: - Main
  static func switchToMain() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
                appDelegate.window?.rootViewController = rootViewController
            }
        }
    

    //MARK: - SwipeViews
    func loadSwipeFriendsVC(){
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let swipeFriendsVC = storyboard.instantiateViewController(withIdentifier: "SwipeFriendsVC") as! SwipeFriendsVC
        
        
        UIApplication.shared.windows.first?.rootViewController = MyTransition(rootViewController:swipeFriendsVC )
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
    
    
    func loadSearchFriendsVC() {
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let  searchFriendsVC = storyboard.instantiateViewController(withIdentifier: "SearchFriendsVC") as! SearchFriendsVC

        searchFriendsVC.modalPresentationStyle = .overCurrentContext
        self.present(searchFriendsVC, animated: true, completion: nil)
    }

    
    func  loadGroupMatchedVC(group:Group,matchType:String,callback:@escaping PressOkay) {
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let  groupMatchedVC = storyboard.instantiateViewController(withIdentifier: "GroupMatchedVC") as! GroupMatchedVC
        
        groupMatchedVC.matchType = matchType
        groupMatchedVC.matchGroup = group
        groupMatchedVC.callback = callback
        groupMatchedVC.modalPresentationStyle = .overCurrentContext
        self.present(groupMatchedVC, animated: true, completion: nil)
    }
    
    //MARK: - MessagingViews
    func loadMessagingVC(callback:@escaping PressOkay) -> MessagesVC{
        let storyboard = UIStoryboard(name: "MessagingViews", bundle: nil)
        let messagesVC = storyboard.instantiateViewController(withIdentifier: "MessagesVC") as! MessagesVC
        
        messagesVC.callback = callback
        
        return messagesVC
    }

    func loadChatGroupVC(matchId:Int, group : Group , callback:@escaping matchStatusUpdate ){
        let storyboard = UIStoryboard(name: "MessagingViews", bundle: nil)
        let chatGroupVC = storyboard.instantiateViewController(withIdentifier: "ChatGroupVC") as! ChatGroupVC

        chatGroupVC.groupId = group.id
        chatGroupVC.matchId = matchId
        chatGroupVC.personalChat = matchId == 0 ? true : false
        chatGroupVC.group = group
        
        chatGroupVC.callback = callback

        
        Utils.transtion = false
        self.show(chatGroupVC, sender: nil)
    }
    

    //MARK: - ProfileViews        
    func loadUserProfileVC(user:User,group:Group?){
        let storyboard = UIStoryboard(name: "ProfileViews", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC

        userProfileVC.user = user
        userProfileVC.group = group
        userProfileVC.numImages = user.photos.count
        
        Utils.transtion = false
        self.show(userProfileVC, sender: nil)
    }

    func loadOtherUserProfileVC(user:User,group:Group,callback:@escaping OtherUserProfile){
        let storyboard = UIStoryboard(name: "ProfileViews", bundle: nil)
        let userProfileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileVC") as! UserProfileVC

        userProfileVC.user = user
        userProfileVC.group = group
        userProfileVC.numImages = user.photos.count
        userProfileVC.callback = callback

        Utils.transtion = false
        self.show(userProfileVC, sender: nil)
    }

    func loadEditProfileVC(callback:@escaping PressOkay){
        let storyboard = UIStoryboard(name: "ProfileViews", bundle: nil)
        let editProfileVC = storyboard.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
        editProfileVC.callback = callback
        
        Utils.transtion = false
        self.show(editProfileVC, sender: nil)
    }

    func loadActiveProfileVC(callback:@escaping PressOkay) -> ActiveProfileVC{
        let storyboard = UIStoryboard(name: "ProfileViews", bundle: nil)
        let activeProfileVC = storyboard.instantiateViewController(withIdentifier: "ActiveProfileVC") as! ActiveProfileVC
        activeProfileVC.callback = callback
        

        return activeProfileVC
    }
    
    func loadSettingVC() {
        let storyboard = UIStoryboard(name: "ProfileViews", bundle: nil)
        let settingVC = storyboard.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        
       let vc = UINavigationController(rootViewController: settingVC)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }

    
    
    //MARK: - Profile
    func loadNotificationsPermissionVC(callback:@escaping PressOkay) -> NotificationsPermissionVC{
        
        let storyboard = UIStoryboard(name: "MessagingViews", bundle: nil)
        let notificationsPermissionVC = storyboard.instantiateViewController(withIdentifier: "NotificationsPermissionVC") as! NotificationsPermissionVC
        
        notificationsPermissionVC.callback = callback

        return notificationsPermissionVC
    }

    
}


//MARK: -
extension UIButton {
    
    func getContinueAttributedText() -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: "Continue with Phone Number", attributes: [
            .font: UIFont(name: "HelveticaNeue", size: 16.0)!,
            .foregroundColor: UIColor(white: 1.0, alpha: 1.0)
            ])
        
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!, range: NSRange(location: 14, length: 12))

        return attributedString
    }
    
    func selectedGenderBtn(){
        self.borderColor = UIColor("#00D8FF")
        self.setTitleColor(UIColor("#00D8FF"), for: .normal)
        self.isSelected = true
        
    }
    
    func unSelectGender(){
        self.borderColor = UIColor("#D8D8D8")
        self.setTitleColor(UIColor("#D8D8D8"), for: .normal)
        self.isSelected = false
    }
}


extension UILabel {
    
    func getPrivacyLabel() -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: "By continuing, you agree to both our\n \nTerms and Privacy Policy", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 12.0)!,
            .foregroundColor: UIColor(red: 49.0 / 255.0, green: 66.0 / 255.0, blue: 89.0 / 255.0, alpha: 1.0),
            .kern: 0.51
            ])
        
        attributedString.addAttribute(.foregroundColor, value: UIColor(white: 0.0, alpha: 1.0), range: NSRange(location: 39, length: 24))
        attributedString.addAttribute(.link, value: "https://www.google.com", range: NSRange(location: 39, length: 5))
        attributedString.addAttribute(.link, value: "https://www.google.com", range: NSRange(location: 49, length: 14))
        
        return attributedString
    }
    
    func getInterestLabel() -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: "Select up to 3 that discribe you best ", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 16.0)!,
            .foregroundColor: UIColor(white: 155.0 / 255.0, alpha: 1.0),
            .kern: -0.12
            ])
        attributedString.addAttributes([
            .font: UIFont(name: "Avenir-BlackOblique", size: 16.0)!,
            .foregroundColor: UIColor(red: 48.0 / 255.0, green: 83.0 / 255.0, blue: 1.0, alpha: 1.0)
            ], range: NSRange(location: 13, length: 1))
        
        return attributedString
    }
    
    func getWelcomeLabel() -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: "Welcome to Hello.", attributes: [
            .font: UIFont(name: "HelveticaNeue", size: 17.0)!,
            .foregroundColor: UIColor(red: 48.0 / 255.0, green: 83.0 / 255.0, blue: 1.0, alpha: 1.0),
            .kern: 0.27
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: 17.0)!, range: NSRange(location: 11, length: 6))
        
        return attributedString
    }
    
    func getDescriptionLabel() -> NSMutableAttributedString {
        
        let attributedString = NSMutableAttributedString(string: "To get the most out of Hello. please\naccept our permission requests", attributes: [
            .font: UIFont(name: "HelveticaNeue", size: 14.0)!,
            .foregroundColor: UIColor.black,
            .kern: 0.27
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!, range: NSRange(location: 23, length: 6))
        attributedString.addAttribute(.font, value: UIFont(name: "HelveticaNeue-Medium", size: 14.0)!, range: NSRange(location: 48, length: 19))
        
        return attributedString
    }
}


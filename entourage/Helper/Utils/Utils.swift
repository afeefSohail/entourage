//
//  Utils.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/27/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import UserNotifications

class Utils{

    static var notificationInChatRoom = false
    static var phoneContacts : [PhoneContact] = []
    static var directFriendShipContacts : [AllContacts] = []
    static var unReadMsgCount = 0
    static var transtion = false
    static var notification = false
    static var mainVC : SwipeFriendsVC?
    static var currVC : BaseVC?
    
    static var updateMyGroup = false {
        didSet{
            if updateMyGroup == true{
                Utils.mainVC?.pageIndex = 1
            }
        }
    }
    
    static var appStatus : Bool = false
    static var chatRoom : Bool = false
    static var chatVC : ChatGroupVC?
    static var otherGroupsUpdate : Bool = false
    static var test = ""
    static var appOpenForNotification = false

    static func resetVariables(){
    
    transtion = false
    notification = false
    mainVC = nil
    currVC = nil
    updateMyGroup = false
    appStatus = false
    chatRoom = false
    chatVC = nil
    otherGroupsUpdate = false
    }
    
    //MARK: - Main
    static func switchToMain() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController() {
            appDelegate.window?.rootViewController = rootViewController
        }
    }
    
    static func switchToOnBoarding() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let rootViewController = UIStoryboard(name: "onBoarding", bundle: nil).instantiateInitialViewController() {
            appDelegate.window?.rootViewController = rootViewController
        }
    }

    public static func initials(fromName name: String?) -> String {
        
        var initials = ""
        
        if let initialsArray = name?.components(separatedBy: " ") {
            if let firstWord = initialsArray.first {
                if let firstLetter = firstWord.first {
                    initials += String(firstLetter).capitalized
                }
            }
            if initialsArray.count > 1, let secondWord = initialsArray.last {
                if let secondLetter = secondWord.first {
                    initials += String(secondLetter).capitalized
                }
            }
        } else {
            initials = "?"
        }
        
        return initials
    }

    static func checkNotificationAuthorizationStatus(callback:@escaping (Bool,String) -> Void){
        
        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { (settings) in
            if settings.authorizationStatus == .notDetermined {

                callback(false,"NotDetermined")
                
            } else if settings.authorizationStatus == .denied {
                
                callback(false,"Denied")
                
            } else if settings.authorizationStatus == .authorized {
                
                callback(true,"Auth")
           
            }
        })
    }

}





//MARK: - MyTransitions
class MyTransition : UINavigationController{
    
    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        
        let animation : CATransition = CATransition()
        animation.duration = 0.5
        animation.type = .push
        
        if Utils.transtion , viewController.title == "Active Profile"{
            
            animation.subtype = .fromLeft
            animation.timingFunction = .init(name: .easeIn)
            self.view.layer.add(animation, forKey: "")
            
            super.pushViewController(viewController, animated: false)

        }else if Utils.transtion , viewController.title == "Message"{
            
         animation.subtype = .fromRight
         animation.timingFunction = .init(name: .easeIn)
         self.view.layer.add(animation, forKey: "")
         
         super.pushViewController(viewController, animated: false)

        }else{
            
            super.pushViewController(viewController, animated: animated)
        }
        
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        
        let animation : CATransition = CATransition()
        animation.duration = 0.5
        animation.type = .push
        
        if Utils.transtion , self.viewControllers.last?.title ?? "" == "Active Profile"{

            animation.subtype = .fromRight
            animation.timingFunction = .init(name: .easeOut)
            self.view.layer.add(animation, forKey: "")
            
            return  super.popViewController(animated: false)

        }else if Utils.transtion , self.viewControllers.last?.title ?? "" == "Message"{
            
            
         animation.subtype = .fromLeft
         animation.timingFunction = .init(name: .easeOut)
         self.view.layer.add(animation, forKey: "")

         return  super.popViewController(animated: false)

        }else{
            
            return  super.popViewController(animated: animated)

        }
        
    }
 
    
}

//MARK: - AvatarButton
class AvatarBtn : UIButton {
    
    var groupDistance : String? = ""
    var user : User?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

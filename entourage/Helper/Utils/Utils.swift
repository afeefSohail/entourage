//
//  Utils.swift
//  entourage
//

import UIKit
import SwiftUI
import UserNotifications

class Utils{

    static var notificationInChatRoom = false
    static var phoneContacts : [PhoneContact] = []
    static var directFriendShipContacts : [AllContacts] = []
    static var unReadMsgCount = 0
    static var transtion = false
    static var notification = false
    static var updateMyGroup = false
    static var otherGroupsUpdate : Bool = false
    static var appOpenForNotification = false

    static func resetVariables(){
        transtion = false
        notification = false
        updateMyGroup = false
        otherGroupsUpdate = false
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
            return super.popViewController(animated: false)
        }else if Utils.transtion , self.viewControllers.last?.title ?? "" == "Message"{
            animation.subtype = .fromLeft
            animation.timingFunction = .init(name: .easeOut)
            self.view.layer.add(animation, forKey: "")
            return super.popViewController(animated: false)
        }else{
            return super.popViewController(animated: animated)
        }
    }
}

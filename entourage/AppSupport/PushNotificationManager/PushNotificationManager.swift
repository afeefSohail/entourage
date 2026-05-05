//
//  PushNotificationManager.swift
//  FirebaseStarterKit
//
//  Created by Florian Marcu on 1/28/19.
//  Copyright © 2019 Instamobile. All rights reserved.
//

import Firebase
import FirebaseMessaging
import UIKit
import UserNotifications

class PushNotificationManager: NSObject {
    
    fileprivate static let _shared = PushNotificationManager()
    
    class var sharedInstance : PushNotificationManager {
        return _shared
    }
    
    func registerForPushNotifications(callback:@escaping (Bool)->Void) {


        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (status, error) in
            if error == nil{
                callback(status)
            }else{
                callback(false)
            }
        }
        
    }
    
        
}

//
//  AppDelegate.swift
//  entourage
//
//  Created by Furqan Ahmad on 23/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwiftUI
import UserNotifications
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Badge Number
        UIApplication.shared.applicationIconBadgeNumber = 0
        
                //GMT 0
        //       TimeZone.ReferenceType.default = TimeZone(abbreviation: "UTC")!

        //       TimeZone.ReferenceType.default = TimeZone(abbreviation: "EST")!


        setUpFireBaseConfig()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {}
    
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {}
    
    func applicationDidBecomeActive(_ application: UIApplication) {}
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("app terminte")
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        return Auth.auth().canHandle(url)
    }
    
    func setUpFireBaseConfig(){
        
        
        if FirebaseApp.app() == nil {
            
            FirebaseApp.configure()

        }else{
            
            updateFirebasePushTokenIfNeeded()
        }
        
        callNotificationDelegate()
        
    }
    
    private func callNotificationDelegate(){

        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    

    
}


extension AppDelegate : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        
        if UIApplication.shared.applicationState == .active { // In iOS 10 if app is in foreground do nothing.
            completionHandler([])
        } else { // If app is not active you can show banner, sound and badge.
            completionHandler([.alert, .badge, .sound])
        }

    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
            
        
        let payload = response.notification.request.content.userInfo
        
        guard let notificationData = payload as? [String : Any] else{
            return
        }
        
        let type =  notificationData["notifiable_type"] as! String
        let id = Int(notificationData["notifiable_id"]  as! String) ?? 0
        let Notification_type = notificationData["notification_type"]  as? String ?? ""
        
        
        if type == "Message" {
            let groupId = Int(notificationData["group_id"] as! String) ?? 0
            UserDefaults.standard.set(id, forKey: "chat_id")
            UserDefaults.standard.set(groupId, forKey: "group_id")
            UserDefaults.standard.set(type, forKey: "notifiable_type")
        } else if type == "MatchCreated" {
            UserDefaults.standard.set(id, forKey: "match_id")
            UserDefaults.standard.set(type, forKey: "notifiable_type")
        } else if type == "FriendshipRequest" || type == "FriendshipAccepted" {
            UserDefaults.standard.set(type, forKey: "notifiable_type")
        }
        completionHandler()
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
    
        
        guard let notificationData = userInfo as? [String : Any] else{
            return
        }
        
        let type =  notificationData["notifiable_type"] as? String ?? ""
        let id = Int(notificationData["notifiable_id"]  as? String ?? "") ?? 0
        let Notification_type = notificationData["notification_type"]  as? String ?? ""

        if type == "Message" {
            let groupId = Int(notificationData["group_id"] as? String ?? "") ?? 0
            UserDefaults.standard.set(id, forKey: "chat_id")
            UserDefaults.standard.set(groupId, forKey: "group_id")
            UserDefaults.standard.set(type, forKey: "notifiable_type")
        } else if type == "MatchCreated" {
            UserDefaults.standard.set(id, forKey: "match_id")
            UserDefaults.standard.set(type, forKey: "notifiable_type")
        } else if type == "FriendshipRequest" || type == "FriendshipAccepted" {
            UserDefaults.standard.set(type, forKey: "notifiable_type")
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
        
        
        
    }
    

    
}


extension AppDelegate:MessagingDelegate{
    
    func subscribeForNotification() {
        Messaging.messaging().subscribe(toTopic: "broadcastMessage")
    }
    
    func unSubscribeFromNotification() {
        
        //Subscribe for Broadcast notification
        Messaging.messaging().unsubscribe(fromTopic: "broadcastMessage")
        
    }
    
    func updateFirebasePushTokenIfNeeded() {
        
        if let token = Messaging.messaging().fcmToken {
            
            WebServicesManager.shared.registerForNotificationsWith(fcmToken: token) { (_, _) in
                
            }
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        updateFirebasePushTokenIfNeeded()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //When the notifications of this code worked well, there was not yet.
        Messaging.messaging().apnsToken = deviceToken
    }
    
    
    
}

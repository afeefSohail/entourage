//
//  AppDelegate.swift
//  entourage
//
//  Created by Furqan Ahmad on 23/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseAuth

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window?.tintColor = UIColor(named: "themeColor")
        
        //Badge Number
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        self.window?.backgroundColor = UIColor.white
        
                //GMT 0
        //       TimeZone.ReferenceType.default = TimeZone(abbreviation: "UTC")!

        //       TimeZone.ReferenceType.default = TimeZone(abbreviation: "EST")!


        setUpFireBaseConfig()
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
        if Utils.chatRoom == true{
            Utils.chatVC?.changeUserChatStatus(status: false) {}
        }
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        if Utils.chatRoom == true{
            Utils.chatVC?.changeUserChatStatus(status: false) {}
        }
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if Utils.chatRoom == true{
            Utils.chatVC?.changeUserChatStatus(status: true) {}
        }
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if Utils.chatRoom == true{
            Utils.chatVC?.changeUserChatStatus(status: true) {}
        }
        
    }
    
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
    
    private func HomeScreen(){
        let storyboard = UIStoryboard(name: "SwipeViews", bundle: nil)
        let swipeFriendsVC = storyboard.instantiateViewController(withIdentifier: "SwipeFriendsVC") as! SwipeFriendsVC
        
        UIApplication.shared.keyWindow?.rootViewController = MyTransition(rootViewController:swipeFriendsVC )
        UIApplication.shared.keyWindow?.makeKeyAndVisible()
    }
    
}


extension AppDelegate : UNUserNotificationCenterDelegate{
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        Utils.test = "Bhagarat"
        
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
        Utils.test = "Kamina"
        
        
        if type == "Message"{
            
            let groupId = Int(notificationData["group_id"]  as! String ) ?? 0
            
            if (User.needsLogin() == false),Utils.appStatus == true{                
                self.activeAppNotifications(id: id, type: type, didTap: true, notificationType: Notification_type)
            }else{
                
                UserDefaults.standard.set(id, forKey: "chat_id")
                UserDefaults.standard.set(groupId, forKey: "group_id")
                UserDefaults.standard.set(type, forKey: "notifiable_type")
                completionHandler()
            }
        }else if type == "MatchCreated"{
            
            if (User.needsLogin() == false),Utils.appStatus == true{
                self.activeAppNotifications(id: id, type: type, didTap: true, notificationType: Notification_type)
            }else{
                UserDefaults.standard.set(id, forKey: "match_id")
                UserDefaults.standard.set(type, forKey: "notifiable_type")
            }
            
            completionHandler()
            
        }else if type == "FriendshipRequest"{
            
            if (User.needsLogin() == false),Utils.appStatus == true{
                self.activeAppNotifications(id: id, type: type, didTap: true, notificationType: Notification_type)
            }else{
                UserDefaults.standard.set(type, forKey: "notifiable_type")
            }

            completionHandler()
        }else if type == "FriendshipAccepted"{
            
            if (User.needsLogin() == false),Utils.appStatus == true{
                self.activeAppNotifications(id: id, type: type, didTap: true, notificationType: Notification_type)
            }else{
                UserDefaults.standard.set(type, forKey: "notifiable_type")
            }
            
            completionHandler()
        }
        
        
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Utils.test = "Chawal"
    
        
        guard let notificationData = userInfo as? [String : Any] else{
            return
        }
        
        let type =  notificationData["notifiable_type"] as? String ?? ""
        let id = Int(notificationData["notifiable_id"]  as? String ?? "") ?? 0
        let Notification_type = notificationData["notification_type"]  as? String ?? ""

        if (User.needsLogin() == false),Utils.appStatus == true{
            
            //Push Notifications
            if type == "Message" || type == "MatchCreated" {
                self.activeAppNotifications(id: id, type: type,didTap: false, notificationType: Notification_type)
            }else if type == "FriendshipRequest" || type == "FriendshipAccepted"{
                
                if Notification_type == "silent"{
                    self.activeAppNotifications(id: id, type: type,didTap: true, notificationType: Notification_type)
                }else{
                    self.activeAppNotifications(id: id, type: type,didTap: false, notificationType: Notification_type)
                }

            }else{//Silent Notifications
                self.activeAppNotifications(id: id, type: type,didTap: true, notificationType: Notification_type)
            }
            
        }else{//When App is Open By Push Notiofication Press Action
            
            if type == "Message"{
                
                let groupId = Int(notificationData["group_id"]  as! String ) ?? 0
                UserDefaults.standard.set(id, forKey: "chat_id")
                UserDefaults.standard.set(groupId, forKey: "group_id")
                UserDefaults.standard.set(type, forKey: "notifiable_type")
                
            }else if type == "MatchCreated"{
                
                UserDefaults.standard.set(id, forKey: "match_id")
                UserDefaults.standard.set(type, forKey: "notifiable_type")
                
            }else if type == "FriendshipRequest"{
                    UserDefaults.standard.set(type, forKey: "notifiable_type")
            }else if type == "FriendshipAccepted"{
                    UserDefaults.standard.set(type, forKey: "notifiable_type")
            }
       
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
        
        
        
    }
    
    private func activeAppNotifications(id:Int, type:String, didTap:Bool,notificationType:String){
        
        switch type {
        case "GroupInvite":
            print("-> \n",type)
            Utils.updateMyGroup = true
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.ShowGroupInvite(groupId: id)
            }
        case "GroupInviteNew" :
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupStatus()
            }
        case "GroupInviteDeleted" :
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupStatus()
            }
        case "GroupLeft":
            print("-> \n",type)
            Utils.updateMyGroup = true
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupObject(type: "GroupLeft" )
            }
        case "GroupAdd":
            print("-> \n",type)
            Utils.updateMyGroup = true
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupObject(type: "" )
            }
        case "GroupAddNew":
            print("-> \n",type)
            Utils.updateMyGroup = true
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupObject(type: "" )
            }
        case "GroupInviteAccepted":
            print("-> \n",type)
            Utils.updateMyGroup = true
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupObject(type: "" )
            }
        case "GroupInviteDeclined":
            print("-> \n",type)
            Utils.updateMyGroup = true
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updateGroupObject(type: "" )
            }
        case "GroupStatusChanged":
            if (User.needsLogin() == false),Utils.appStatus == true, notificationType == "silent"{
                Utils.currVC?.updateGroupStatus()
            }
        case "MatchCreated":
            print("-> \n",type)
            if (User.needsLogin() == false),Utils.appStatus == true, didTap == true{
                Utils.currVC?.matchInvite(matchId: id, completeion: {
                    
                })
            }
        case "UnMatch":
            print("-> \n",type)
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.upadteMatchGroup(match_Id: id)
            }
        case "ProfilePicUpdated":
            
            print("-> \n",type)
            if (User.needsLogin() == false),Utils.appStatus == true,notificationType == "silent"{
                Utils.currVC?.updationOfProfilePic()
            }
        case "FriendshipRequest":
            if (User.needsLogin() == false),Utils.appStatus == true,didTap == true{
                Utils.currVC?.FriendShipNotification()
            }
        case "FriendshipAccepted":
            if (User.needsLogin() == false),Utils.appStatus == true,didTap == true{
                Utils.currVC?.FriendShipNotification()
            }
        case "Message":
            print("-> \n",type)
            if (User.needsLogin() == false),Utils.appStatus == true, didTap == true{
                MessageNotification(Id: id)
            }
            
        default:
            print("-> \n",type)
        }
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

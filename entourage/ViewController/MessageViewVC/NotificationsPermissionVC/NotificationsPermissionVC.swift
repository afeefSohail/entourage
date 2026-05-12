//
//  NotificationsPermissionVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Firebase
import UserNotificationsUI
import NotificationCenter

class NotificationsPermissionVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var btn : UIButton!

    
    //MARK:- Class Properties
    var barBtn = UIBarButtonItem()
    var callback: PressOkay!
    var authStatus = ""
    
    override func setupGUI() {
        super.setupGUI()
        
        self.setUpNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!]

        //NavBar shadow
        self.addNavBarShadow()
        self.setUpNavBarButton()
        
        self.title = "Notifications Permission"
        
        self.btn.setTitle("Enable", for: .normal)
        self.btn.backgroundColor = Colors.themeColor.value

        self.showNotificationAlert()
        
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    fileprivate func setUpNavBarButton(){
        
         barBtn = UIBarButtonItem(title: "Skip", style: .plain, target: self, action: #selector(pressSkipBtn))
        barBtn.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Avenir-Book", size: 17)!,
                                       NSAttributedString.Key.foregroundColor:UIColor("#c5c6d5")], for: .normal)
        navigationItem.rightBarButtonItem = barBtn
    }

    func showNotificationAlert() {
        
            Utils.checkNotificationAuthorizationStatus { (status,value) in
                self.authStatus = value
                if status == false{
                    
                    if self.authStatus == "Denied"{
                        
                        DispatchQueue.main.async {
                            self.btn.setTitle("Go To Settings", for: .normal)
                            self.btn.backgroundColor = UIColor.black
                        }
                        
                    }
                    
                }else{
                    
                    DispatchQueue.main.async {
                        UserDefaults.standard.set(1, forKey: "num")
                        self.callback()
                        //Notification permission was already granted
                        self.dismiss(animated: false, completion: nil)

                    }
                }
            }
    }
    
    
    @objc func pressSkipBtn(){
        self.dismiss(animated: false, completion: nil)
    }

    @IBAction func pressEnableBtn(_ sender: Any) {
        if authStatus == "Denied"{
            
            NotificationCenter.default.addObserver(self, selector: #selector(notificationActive), name: UIApplication.didBecomeActiveNotification , object: nil)

            openBrowserWith(url: UIApplication.openSettingsURLString)
            
        }else if authStatus == "NotDetermined"{
            
            PushNotificationManager.sharedInstance.registerForPushNotifications(callback: { (status) in
                self.showNotificationAlert()
            })

        }
    }
    
    @objc func notificationActive(){
        print("What Happend")
        Utils.notification = false
        
        
        self.callback()
        //Notification permission was already granted
        self.dismiss(animated: false, completion: nil)

    }

    
}

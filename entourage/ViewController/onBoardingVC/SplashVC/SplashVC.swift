//
//  SplashVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Contacts

class SplashVC: BaseVC {
    
    var phoneNum : String = ""
    let store = CNContactStore()
    
    override func setupGUI() {
        self.hideNavBar()
        
        
        let when = DispatchTime.now() + 0
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.proceedToNextScreen()
        }
        
    }
    
    fileprivate func proceedToNextScreen() {
        
        let todayDate = Date().localDate()
        print("\(todayDate.hour) , \(todayDate.minute) , \(todayDate.second) --> ",todayDate.getSecondsToday())

        let needsLogin = User.needsLogin()
        
        if needsLogin  ==  false {
            getUser()
        }else{
            self.loadTutorialVC()
        }
        
    }
    
}


// MARK: - User ApiHook
extension SplashVC{
    
    fileprivate func getUser(){
        
        WebServicesManager.shared.getUser { (user, error) in
            if error == nil{
                
                let user = user as! User
                print(User.getToken())
                
                if user.isBlocked == true{
                    
                    let vc = UserBannedVC.loadUserBannedVC(userName: user.user_name ?? "")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else{
                    
                    let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.setUpFireBaseConfig()
                    
                    if user.checkUserInfo() == "Main"{
                        
                        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
                            
                            if UserDefaults.standard.bool(forKey: "contactPermission") == true{
                                UserDefaults.standard.removeObject(forKey: "contactPermission")
                                
                                self.getMatchGroup()

                            }else{
                                
                                self.getMatchGroup()
                                
                                //self.loadProfilePictureVC(root: true)
                                //self.loadAddFirstNameVC(vcType: false)
                                //self.loadAddBirthdayDateVC()
                                //self.loadContactPermissionVC()
                                //self.loadAddFriendsVC()
                                //self.loadTutorialVC()
                                //self.loadCreateUserNameVC(root: true)
                                
                            }
                            
                            
                        }else{
                            UserDefaults.standard.set(true, forKey: "contactPermission")
                            self.loadContactPermissionVC()
                        }
                        
                    }else if user.checkUserInfo() == "Gender"{
                        self.loadGenderSelectedVC()
                    }else if user.checkUserInfo() == "Photos"{
                        self.loadProfilePictureVC(root: true)
                    }else if user.checkUserInfo() == "userName"{
                        self.loadCreateUserNameVC(root: true)
                    }

                }
                
            }else{
                self.showAlert(title: "Error", message: error!)
                self.loadTutorialVC()
            }
        }
    }
    
    fileprivate func getMatchGroup(){
        
        WebServicesManager.shared.matchList { (list, error) in
            
            if error == nil{
                
                if Utils.appStatus == false{
                    Utils.appStatus = true
                    self.loadSwipeFriendsVC()
                    //self.getSettings()
                }
                
            }else{
                self.showAlert(title: "Error", message:error!)
            }
        }
    }
    
    fileprivate func getSettings(){
        
        WebServicesManager.shared.getUserSettings { (response, error) in
            if error == nil{
                
                if Utils.appStatus == false{
                    Utils.appStatus = true
                    self.loadSwipeFriendsVC()
                }
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
}

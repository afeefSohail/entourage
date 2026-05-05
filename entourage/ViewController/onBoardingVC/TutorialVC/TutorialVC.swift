//
//  TutorialVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth
import Contacts

class TutorialVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var mainLbl: UILabel!
    @IBOutlet weak var testTF: UITextField!
    
    //MARK:- Class Properties
    var pageIndex = 0
    var phoneNum : String = ""
    
    // Tracks the currently centered cell.
    
    override func setupGUI() {
        super.setupGUI()
                
        let lblText = "By tapping Continue with Phone Number, you  agree to our Terms. Learn how  we  proccess  your data  in our Privacy Policy."
        mainLbl.createTapLabls(text:lblText  , inRange: [NSRange(location:57 , length: 5),NSRange(location:106 , length: 14)])

        mainLbl.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapLabel)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    //MARK: - Class Function
    override func updateGUI() {
        
    }
    
    @IBAction func tapLabel(gesture: UITapGestureRecognizer) {
        if gesture.didTapAttributedTextInLabel(label: mainLbl, inRange: NSRange(location:57 , length: 5)) {
            loadExtrenal(url: "https://www.entourage-app.com/terms-of-service.php")
        } else if gesture.didTapAttributedTextInLabel(label: mainLbl, inRange: NSRange(location:106 , length: 14)) {
            loadExtrenal(url: "https://www.entourage-app.com/privacy-policy.php")
        } else {
            print("Tapped none")
        }
    }
}


// MARK: - Api Hook
extension TutorialVC{
    
    func userSignUp(){
        self.startAnimation()
        WebServicesManager.shared.UserSignUpBy(phoneNum: self.phoneNum) { (User, error) in
            
            if error == nil{
                
                
                let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                appDelegate?.setUpFireBaseConfig()
                
                //Auth.auth().signInAnonymously(completion: nil)
                self.getSettingsForOnBoarding()
            }else{
                self.stopAnimation()
                if error! == "phone number already exist."{
                    self.getUserBy()
                }else{
                    self.showAlert(title: "Error", message: error! )
                }
            }
        }
    }
    
    fileprivate func getSettingsForOnBoarding(){
        WebServicesManager.shared.getUserSettings { (response, error) in
            self.stopAnimation()
            if error == nil{
                self.loadGenderSelectedVC()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    fileprivate func getMatchGroup(){
        
        WebServicesManager.shared.matchList { (list, error) in
            self.stopAnimation()
            
            if error == nil{
                
                Utils.appStatus = true
                self.loadSwipeFriendsVC()

            }else{
                self.stopAnimation()
                self.showAlert(title: "Error", message:error!)
            }
        }
    }
    
    fileprivate func getSettingsForHomeScreen(){
        WebServicesManager.shared.getUserSettings { (response, error) in
            self.stopAnimation()
            if error == nil{
                
                Utils.appStatus = true
                self.loadAddFriendsVC()
                
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    
    fileprivate func getUserBy(){
        self.startAnimation()
        WebServicesManager.shared.getUserBy(phoneNum: self.phoneNum){ (user, error) in
            if error == nil{
                let user = user as! User
                
                if user.isBlocked == true{
                    
                    let vc = UserBannedVC.loadUserBannedVC(userName: user.user_name ?? "")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else{

                    let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.setUpFireBaseConfig()
                    
                    Auth.auth().signInAnonymously(completion: nil)
                    
                    if user.checkUserInfo() == "Main"{
                        
                        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
                            
                            if UserDefaults.standard.bool(forKey: "contactPermission") == true{
                                UserDefaults.standard.removeObject(forKey: "contactPermission")
                                self.stopAnimation()
                                self.loadAddFriendsVC()
                            }else{
                                self.getMatchGroup()
                            }
                            
                            
                        }else{
                            self.stopAnimation()
                            UserDefaults.standard.set(true, forKey: "contactPermission")
                            self.loadContactPermissionVC()
                        }
                        
                    }else if user.checkUserInfo() == "Gender"{
                        self.stopAnimation()
                        self.loadGenderSelectedVC()
                    }else if user.checkUserInfo() == "Photos"{
                        self.stopAnimation()
                        self.loadProfilePictureVC(root: true)
                    }else if user.checkUserInfo() == "userName"{
                        self.stopAnimation()
                        self.loadCreateUserNameVC(root: true)
                    }

                
                }
            }else{
                self.stopAnimation()
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
    
}

// MARK: - Actions
extension TutorialVC{
    
    @IBAction func pressContniueBtn(_ sender: Any) {
        self.loadPhoneNumVerifyVC()
        
    }
    
    @IBAction func privacyPolicyBtnPressed(_ sender: UIButton) {
        loadExtrenal(url: "https://www.entourage-app.com/privacy-policy.php")
    }

    @IBAction func suggestionBtnPressed(_ sender: UIButton) {
        loadExtrenal(url: "https://www.entourage-app.com/faq.php")
    }
}



// MARK: - UITextField
extension TutorialVC : UITextFieldDelegate{
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.phoneNum = textField.text ?? ""
        
        self.userSignUp()
        textField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.phoneNum = textField.text ?? ""
        
        self.userSignUp()
        textField.resignFirstResponder()
        return true
    }
    
    
}

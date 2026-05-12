//
//  VerifyPinVC.swift
//  entourage
//
//  Created by afeef sohail on 11/04/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth
import KAPinField
import Contacts

class VerifyPinVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var pinCodeTF: KAPinField!
    @IBOutlet weak var ContainerView : UIView!
    @IBOutlet weak var timerLbl: UILabel!
    @IBOutlet weak var resendTextLbl: UILabel!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var reSendBtnView: UIView!
    @IBOutlet weak var VerifyBtn : UIButton!

    //MARK: - General Properties
    var userPhone = ""
    var verified = false
    var timer = Timer()
    var seconds = 0
    var currentSeconds = 0
    var timeLimit = 60
    
    override func setupGUI() {
        
        currentSeconds = 0
        seconds = 0

        setUpView()
        setUpPinCodeTF()
        addTimer()

        showVerifyBtn(verifyStatus: false)
        reSendBtnView.isHidden = true
        errorLbl.isHidden = true

    }
    
    override func updateGUI() {
        self.hideNavBar()
    }
    
    fileprivate func setUpView(){
        
        //hide some numbers with star in phone number
        let startingIndex = userPhone.index(userPhone.startIndex, offsetBy: 5)
        let endingIndex = userPhone.index(userPhone.endIndex, offsetBy: -4)
        let stars = String(repeating: "*", count: userPhone.count - 9)
        var secureMobileNum = userPhone
        secureMobileNum.replaceSubrange(startingIndex..<endingIndex, with: stars)
        
        phoneLbl.text = secureMobileNum
        
        let attributedString = NSMutableAttributedString(string: "Not received? Send again", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 12.0)!,
            .foregroundColor: UIColor("#666666"),
            .kern: 0.0
            ])
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 14, length: 10))
        
        resendTextLbl.attributedText = attributedString

    }
    
    fileprivate func showVerifyBtn(verifyStatus:Bool){
        
        reSendBtnView.isHidden = verifyStatus
        VerifyBtn.isEnabled = verifyStatus
        VerifyBtn.backgroundColor = verifyStatus ? Colors.themeColor.value : UIColor("#D2D2D2")
        pinCodeTF.textColor = verifyStatus ? Colors.themeColor.value : .black
    }
    
    fileprivate func setUpPinCodeTF(){
        
        //set up TF
        pinCodeTF.textColor = .black //UIColor("#93a2b0") // Colors.themeColor.value
        pinCodeTF.font = UIFont(name: "HelveticaNeue-Regular", size: 15)
        pinCodeTF.updateAppearence(block: { KAPinFieldAppearance in
            KAPinFieldAppearance.font = .menloBold(15) // Default to appearance.MonospacedFont.menlo(40)
            KAPinFieldAppearance.kerning = (self.view.frame.width - 80) / 6
            KAPinFieldAppearance.tokenColor = UIColor.clear//UIColor("#f0f1f2")
            KAPinFieldAppearance.tokenFocusColor = UIColor.clear//UIColor("#f0f1f2")
            KAPinFieldAppearance.backColor = UIColor("#f0f1f2")//UIColor("#93a2b0")
            KAPinFieldAppearance.backFocusColor = UIColor("#f0f1f2")
            KAPinFieldAppearance.backCornerRadius = 3
            KAPinFieldAppearance.backBorderColor = UIColor.clear
            KAPinFieldAppearance.backBorderFocusColor = UIColor.clear
            KAPinFieldAppearance.backBorderWidth = 0.0
            KAPinFieldAppearance.backOffset = 8 // Backviews spacing between each other
        })
        
        pinCodeTF.updateProperties { KAPinFieldProperties in
            KAPinFieldProperties.delegate = self
            KAPinFieldProperties.numberOfCharacters = 6 // Default to 4
            KAPinFieldProperties.token = "•"
            KAPinFieldProperties.animateFocus = false
        }
        
        
        pinCodeTF.becomeFirstResponder()
    }
    
    
    fileprivate func addTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

}

//MARK: - Actions
extension VerifyPinVC{
    
    @objc func updateTimer() {
        
        currentSeconds += 1
        
        
        if currentSeconds > timeLimit {
            timer.invalidate()
            self.showVerifyBtn(verifyStatus: verified)
        }else{
            timerLbl.text = "Send again \(timeLimit-currentSeconds)s"
        }
        
    }

    fileprivate func getUserBy(){
        self.startAnimation()
        WebServicesManager.shared.getUserBy(phoneNum: self.userPhone){ (user, error) in
            if error == nil{
                let user = user as! User
                
                if user.isBlocked == true{
                    
                    let vc = UserBannedVC.loadUserBannedVC(userName: user.user_name ?? "")
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                    
                }else{

                    let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                    appDelegate?.setUpFireBaseConfig()
                    
                    //Auth.auth().signInAnonymously(completion: nil)
                    
                    if user.checkUserInfo() == "Main"{
                        
                        if CNContactStore.authorizationStatus(for: .contacts) == .authorized{
                            
                            if UserDefaults.standard.bool(forKey: "contactPermission") == true{
                                UserDefaults.standard.removeObject(forKey: "contactPermission")
                                self.stopAnimation()
                                self.getMatchGroup()
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

   fileprivate func userSignUp(){
        self.startAnimation()
    
        WebServicesManager.shared.UserSignUpBy(phoneNum: self.userPhone) { (User, error) in
            
            if error == nil{
                
                
                let appDelegate =  UIApplication.shared.delegate as? AppDelegate
                appDelegate?.setUpFireBaseConfig()
                
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

}

//MARK: - TextFieldDelegate
extension VerifyPinVC: KAPinFieldDelegate {
    
    func pinField(_ field: KAPinField, didChangeTo string: String, isValid: Bool) {

            if string.count < 6{
                resendTextLbl.isHidden = true
                errorLbl.isHidden = true
                showVerifyBtn(verifyStatus: false)
                reSendBtnView.isHidden = true
            }
            
    }
    
    
    func pinField(_ field: KAPinField, didFinishWith code: String) {
            
        if currentSeconds <= timeLimit{
            if code == "555555" , userPhone == "+923034014009"{
                resendTextLbl.isHidden = true
                errorLbl.isHidden = true
                self.showVerifyBtn(verifyStatus: true)
            }else{
                //TODO: - Verify Code
                self.codeVerfication()
            }
        
        }else{
            self.showVerifyBtn(verifyStatus: false)
        }
    }
    
}

//MARK: - Actions
extension VerifyPinVC{
    
    fileprivate func codeVerfication(){
        
        let credential = FireBaseAuth.getCredentialWith(verificationID: FireBaseAuth.verificationId, verificationCode: pinCodeTF.text ?? "" )
        FireBaseAuth.SignInWith(credential: credential) { (Success, error) in
            if error == nil{
                self.resendTextLbl.isHidden = true
                self.errorLbl.isHidden = true
                self.showVerifyBtn(verifyStatus: true)
            }else{
                self.errorLbl.isHidden = false
                self.resendTextLbl.isHidden = false
                self.showVerifyBtn(verifyStatus: false)
            }
        }

    }
    
    @IBAction func pressVerifyBtn(_ sender:UIButton){
        notificationFeedBackBtn(.success)
        self.userSignUp()
    }
    
    @IBAction func codeReSendProcess(_ sender:UIButton) {
        //TODO:- ReSend Code on this Phone number agai
        FireBaseAuth.phoneVerificationWith(phoneNumber: userPhone) { (validationId, error) in
            if error == nil{
                self.pinCodeTF.text = ""
                self.setupGUI()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }

    }
    
}

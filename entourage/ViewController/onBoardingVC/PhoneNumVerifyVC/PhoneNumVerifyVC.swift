//
//  PhoneNumVerifyVC.swift
//  entourage
//
//  Created by afeef sohail on 11/04/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth
import FlagPhoneNumber
import FittedSheets

class PhoneNumVerifyVC: BaseVC {
    
    @IBOutlet weak var phoneNumberTF: FPNTextField!
    @IBOutlet weak var termsLbl: UILabel!
    

    //MARK: - Genral properties
    var listController: FPNCountryListViewController = FPNCountryListViewController(style: .grouped)
    var isPhoneNumberValidated = false // TODO: Change to false when stop populating test number
    var phoneNumber = ""
    var countryCode = "+1"
    
    override func setupGUI() {
        
        phoneNumberTF.flagButtonSize = CGSize(width: 46, height: 49)
        phoneNumberTF.flagButton.addTarget(self, action: #selector(pressFlagBtn), for: .touchUpInside)

        phoneNumberTF.hasPhoneNumberExample = false // true by default
        phoneNumberTF.placeholder = "Enter your mobile number"
        phoneNumberTF.delegate = self
        phoneNumberTF.displayMode = .list // .picker by default
        phoneNumberTF.set(phoneNumber: "+923034014009")
        
        listController.setup(repository: phoneNumberTF.countryRepository)
        listController.didSelect = { [weak self] country in
        self?.phoneNumberTF.setFlag(countryCode: country.code)
        self?.phoneNumberTF.becomeFirstResponder()
            
        }
        
        
        let attributedString = NSMutableAttributedString(string: "By clicking Continue I here by agree to the Terms & Conditions & acknowledge that I have read the Privacy Policy.", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 12.0)!,
            .foregroundColor: UIColor("#878f96"),
            .kern: 0.0
        ])
        
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 44, length: 18))
        attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 98, length: 14))
        
        termsLbl.attributedText = attributedString
    }
    
    override func updateGUI() {
        self.hideNavBar()
    }
    
    
    @objc func pressFlagBtn(sender:UIButton){
        phoneNumberTF.resignFirstResponder()
    }
    
    fileprivate func checkUserUniquenes(){
        
    }
        
}

//MARK: - Action
extension PhoneNumVerifyVC{
    
    @IBAction func pressSendSmsBtn(_ Sender:UIButton){
        
        if isPhoneNumberValidated {
            notificationFeedBackBtn(.success)
            phoneNumber = phoneNumber.replacingOccurrences(of: "-", with: "")
            phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")

            var completePhoneNum = countryCode
            
            completePhoneNum += phoneNumber
            self.loadVerifyPinVC(phoneNumber: completePhoneNum)

//            FireBaseAuth.phoneVerificationWith(phoneNumber: completePhoneNum) { (validationId, error) in
//                if error == nil{
//                    self.loadVerifyPinVC(phoneNumber: completePhoneNum)
//                }else{
//                    self.showAlert(title: "Error", message: error!)
//                }
//            }

        }else{
            phoneNumberTF.shake()
        }

    }
}

//MARK:- FPNTextFieldDelegate
extension PhoneNumVerifyVC: FPNTextFieldDelegate {
    
    func fpnDisplayCountryList() {
        
        let navigationViewController = UINavigationController(rootViewController: listController)
        listController.title = "Countries"
        
        var options = SheetOptions()
        options.pullBarHeight = 0              // replaces handleSize + handleTopEdgeInset + handleBottomEdgeInset
        options.shouldExtendBackground = false // replaces extendBackgroundBehindHandle
        options.useFullScreenMode = false
        
        let sheetController = SheetViewController(controller: navigationViewController, sizes: [.fixed(self.view.frame.height * 0.5)], options: options)
        
        sheetController.cornerRadius = 16          // replaces topCornersRadius
        sheetController.dismissOnOverlayTap = true // replaces dismissOnBackgroundTap
        sheetController.pullBarBackgroundColor = .clear
        sheetController.contentViewController.pullBarView.isHidden = true // replaces handleView.isHidden
        sheetController.allowPullingPastMaxHeight = false
        sheetController.overlayColor = UIColor.black.withAlphaComponent(0.5)
        
        sheetController.didDismiss = { _ in
            print("Will dismiss ")
        }
        
        self.present(sheetController, animated: false, completion: nil)

//        self.present(navigationViewController, animated: true, completion: nil)
    }
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        
        countryCode = "\(dialCode)"
        print(name, dialCode, code) // Output "France", "+33", "FR"
    }
    
    func fpnDidValidatePhoneNumber(textField: FPNTextField, isValid: Bool) {
        
        phoneNumber = textField.text ?? ""
        isPhoneNumberValidated = isValid
        textField.rightViewMode =  isValid ? .always : .never
        
    }
    
}

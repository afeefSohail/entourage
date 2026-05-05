//
//  AddFirstNameVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/9/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class AddFirstNameVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var vcTitleLbl: UILabel!
    @IBOutlet weak var tfDescLbl: UILabel!
    
    //MARK:- Class Properties
    var vcType = false
    
    override func setupGUI() {
        super.setupGUI()
        
        //set the BackButton
        self.useBackButton(image: UIImage(named: "chevron-back")!)

        //NavBar shadow
        self.addNavBarShadow()
        
        //NavBar Title
        self.title = vcType == true ? "Last Name" : "First Name"
        self.userNameTF.placeholder = vcType == true ? "Last Name" : "First Name"
        
        userNameTF.becomeFirstResponder()
        
        userNameTF.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        vcTitleLbl.text = vcType == true ? "What’s your last name?" : "What’s your first name?"
        tfDescLbl.text = vcType == true ? "Only your first name will be public." : "This is how it will be displayed."
        
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        vcTitleLbl.textColor = textField.text?.isEmpty ?? true ? UIColor("#c5c6d5") : .black

        
        if textField.text!.count >= 3 {
            self.ContinueBtn.isEnabled = true //enable nextBtn id userName Valid
            ContinueBtn.backgroundColor = Colors.themeColor.value
            ContinueBtn.isUserInteractionEnabled = true
        }else{
            ContinueBtn.isEnabled = false//enable nextBtn id userName Valid
            ContinueBtn.backgroundColor = UIColor("#D2D2D2")
        }
    }
    
    @IBAction func pressContinue(_ sender: Any) {
        userNameTF.resignFirstResponder()
        continueFeedBackBtn(.soft)
        if vcType == true{
            EntourageManager.shared.user.last_name = (userNameTF.text ?? "")
            loadAddBirthdayDateVC()
        }else{
            EntourageManager.shared.user.first_name = (userNameTF.text ?? "")
            loadAddFirstNameVC(vcType: true)
        }
        
    }
    
    
    @IBAction func textFieldChange(_ sender: Any) {
        
        if userNameTF.text?.isEmpty == false{
            ContinueBtn.isEnabled = true //enable nextBtn id userName Valid
            ContinueBtn.backgroundColor = UIColor("#00D8FF")
            userNameTF.textAlignment = .center
            
        }else{
            ContinueBtn.isEnabled = false//enable nextBtn id userName Valid
            ContinueBtn.backgroundColor = UIColor("#D2D2D2")
            userNameTF.textAlignment = .left
        }
        
    }
    
}

//MARK: - TextFieldDelegate
extension AddFirstNameVC : UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textAlignment = .center
    }
}

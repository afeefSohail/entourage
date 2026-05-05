//
//  PickUserNameVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class CreateUserNameVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var userNameTF: UITextField!
    @IBOutlet weak var tfStatusImage: UIImageView!
    @IBOutlet weak var editingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var validOrInValidStautsLabel: UILabel!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var vcTitleLbl: UILabel!

    //MARK:- Class Properties

    override func setupGUI() {
        super.setupGUI()
        
        self.showNavBar()
        
        //set the BackButton
        self.useBackButton(image: UIImage(named: "chevron-back")!)
        
        //NavBar shadow
        self.addNavBarShadow()
        //NavBar Title
        self.title = "Create a Username"
        
        self.ContinueBtn.isEnabled = false//enable nextBtn id userName Valid
        self.ContinueBtn.backgroundColor = UIColor("#D2D2D2")

        userNameTF.becomeFirstResponder()
        
    }
    

}

//MARK: - Actions
extension CreateUserNameVC{

    @IBAction func pressContinue(_ sender: Any) {
        continueFeedBackBtn(.soft)
        self.editingIndicator.stopAnimating()
        self.userNameTF.resignFirstResponder()
        
        self.startAnimation()
        WebServicesManager.shared.editUserProfile(checkAge: false ) { (user, error) in
            self.stopAnimation()
            
            if error == nil {
                self.loadContactPermissionVC()
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }

        
    }

    @IBAction func textFieldChange(_ sender: Any) {
        
        if userNameTF.text?.isEmpty == false{

            self.tfStatusImage.isHidden = true
            self.validOrInValidStautsLabel.isHidden = true
            self.editingIndicator.startAnimating()
            
            userNameTF.text = userNameTF.text!.lowercased()
            vcTitleLbl.textColor = .black

            WebServicesManager.shared.checkUserNameAvailablityBy(userName: userNameTF.text!) { (message, error) in

                self.editingIndicator.stopAnimating()
                self.tfStatusImage.isHidden = false
                self.validOrInValidStautsLabel.isHidden = false

                let array = Constants.filterWords.filter({self.userNameTF.text?.contains($0) ?? false })
                
                
                if error == nil , self.userNameTF.text!.containsEmoji == false , array.count == 0 {
                    self.userNameValid()
                }else{
                    self.userNameInValid()
                }
            }
            
        }else{
            
            //Hide things You Want
            tfStatusImage.isHidden = true
            validOrInValidStautsLabel.isHidden = true
            vcTitleLbl.textColor = UIColor("#c5c6d5")
            editingIndicator.startAnimating()
            validOrInValidStautsLabel.textColor = UIColor("#00D8FF")//userName label Text Color in Start

        }
    }

    fileprivate func userNameValid(){
        EntourageManager.shared.user.user_name = self.userNameTF.text!
        
        tfStatusImage.image = UIImage(named: "validTF")//valid userName status image
        validOrInValidStautsLabel.text = "Username Available"//valid userName status text
        validOrInValidStautsLabel.textColor = UIColor("#50E3C2")//Valid userName label Text Color
        userNameTF.textColor = UIColor("#50E3C2")//Valid userName Text Color
        
        ContinueBtn.isEnabled = true//enable nextBtn id userName Valid
        ContinueBtn.backgroundColor = UIColor("#00D8FF")
        
    }
    
    fileprivate func userNameInValid(){
        tfStatusImage.image = UIImage(named: "invalidTF")//InValid userName status image
        validOrInValidStautsLabel.text = "Not Available or Invalid Characters"//InValid userName status text
        validOrInValidStautsLabel.textColor = UIColor("#FF3903")//InValid userName label Text Color
        userNameTF.textColor = UIColor("#FF3903")//InValid userName Text Color
        
        ContinueBtn.isEnabled = false//enable nextBtn id userName Valid
        ContinueBtn.backgroundColor = UIColor("#D2D2D2")
    }

}

extension CreateUserNameVC{
    
    func successAlert(title: String, message: String) -> Void {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
        }))
        present(alert, animated: true, completion: nil)
        
    }

}

// MARK: - UITextFieldDelegate
extension CreateUserNameVC : UITextFieldDelegate{
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //Hide things You Want
        tfStatusImage.isHidden = true
        validOrInValidStautsLabel.isHidden = true
        
        editingIndicator.startAnimating()
        
        validOrInValidStautsLabel.textColor = UIColor("#00D8FF")//userName label Text Color in Start
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }
}

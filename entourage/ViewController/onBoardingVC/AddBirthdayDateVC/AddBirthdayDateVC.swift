//
//  AddBirthdayDateVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/9/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwiftDate

class AddBirthdayDateVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var birthDayTF: UITextField!
    @IBOutlet weak var ageRestrectedLabel: UILabel!
    @IBOutlet weak var ContinueBtn: UIButton!
    @IBOutlet weak var vcTitleLbl: UILabel!

    
    //MARK:- Class Properties
    private var datePicker : UIDatePicker?

    override func setupGUI() {
        super.setupGUI()
        
        //set the BackButton
        self.useBackButton(image: UIImage(named: "chevron-back")!)
        
        //NavBar shadow
        self.addNavBarShadow()
        //NavBar Title
        self.title = "Birthday"

        pressDateBtn()
        
        ageRestrectedLabel.isHidden = true
        
        self.ContinueBtn.isEnabled = false//enable nextBtn id userName Valid
        self.ContinueBtn.backgroundColor = UIColor("#D2D2D2")
    }

    @IBAction func pressContinue(_ sender: Any) {
        continueFeedBackBtn(.soft)
        birthDayTF.resignFirstResponder()
        self.startAnimation()
        WebServicesManager.shared.editUserProfile(checkAge: true ) { (user, error) in
            self.stopAnimation()
            
            if error == nil {
                self.loadProfilePictureVC(root: false)
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }

    }

    func pressDateBtn() {
    
        datePicker = UIDatePicker()
        datePicker?.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker?.preferredDatePickerStyle = .wheels
        }
        
        datePicker?.addTarget(self, action: #selector(pickBirthDate(datePciker:)), for: .valueChanged)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped(gesture:)))
        self.view.addGestureRecognizer(tapGesture)
        
        birthDayTF.inputView = datePicker
        birthDayTF.inputView?.backgroundColor = UIColor.white
        
        birthDayTF.becomeFirstResponder()
    }
    
    func equalDateComaprison() -> Bool{

        let currDate = setDateFormate(date: Date() , formate: dateForamte.month.rawValue)
        let yourDob = stringToDate(date: birthDayTF.text ?? "july 12, 1994" , formate: dateForamte.month.rawValue)
        
        
        return currDate == yourDob ? true : false

    }

    func checkAgeLimit() -> Bool{
        
        let currDate = setDateFormate(date: Date() , formate: dateForamte.month.rawValue)
        let yourDob = stringToDate(date: birthDayTF.text ?? "july 12, 1994" , formate: dateForamte.month.rawValue)
        
        let year = currDate.year - yourDob.year
        
        return year >= (EntourageManager.shared.setting?.min_age ?? 18) ? true : false
        
    }

    
    fileprivate func textFieldChange() {
        
        vcTitleLbl.textColor = birthDayTF.text?.isEmpty ?? true ? UIColor("#c5c6d5") : .black

        if birthDayTF.text?.isEmpty == false , equalDateComaprison() == false , checkAgeLimit() == true{
            
            ContinueBtn.isEnabled = true //enable contBtn
            ContinueBtn.backgroundColor = UIColor("#00D8FF")
            ageRestrectedLabel.isHidden =  true
        }else {
            
            ContinueBtn.isEnabled = false//disable contBtn
            ContinueBtn.backgroundColor = UIColor("#D2D2D2")
            ageRestrectedLabel.isHidden =  birthDayTF.text?.isEmpty == false ?  checkAgeLimit() : true
        }
        
    }
    
    @objc func pickBirthDate(datePciker:UIDatePicker){
        birthDayTF.text = dateToString(date: datePicker?.date ?? Date() , formate: dateForamte.month.rawValue )
        EntourageManager.shared.user.dob = Int((datePicker?.date ?? Date()).timeIntervalSince1970)
        
        
        textFieldChange()
    }
    
    
    @objc func viewTapped(gesture:UITapGestureRecognizer){
        view.endEditing(true)
    }


}

//MARK: - TextFieldDelegate
extension AddBirthdayDateVC : UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textFieldChange()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldChange()
        return true
    }
    
}

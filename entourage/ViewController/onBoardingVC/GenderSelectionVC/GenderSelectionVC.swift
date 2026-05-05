//
//  GenderSelectionVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class GenderSelectionVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var vcTitleLbl: UILabel!

    
    //MARK:- Class Properties
    var flow = false
    
    class func genderSelectedVC(flow:Bool) -> GenderSelectionVC {
        let storyboard = UIStoryboard(name: "onBoarding", bundle: nil)
        let genderSelectionVC = storyboard.instantiateViewController(withIdentifier: "GenderSelectionVC") as! GenderSelectionVC
        genderSelectionVC.flow = flow
        return genderSelectionVC
    }

    
    
    override func setupGUI() {
        super.setupGUI()
        self.setUpNavigationBar()
        
        self.addNavBarShadow()
        
        //NavBar Title
        self.title = "Gender"

        if flow == true{
            
            if EntourageManager.shared.user.gender == "female" {
                getButtonWith(tag: 98, view: self.view).selectedGenderBtn()
            }else if EntourageManager.shared.user.gender == "male" {
                getButtonWith(tag: 99, view: self.view).selectedGenderBtn()
            }else if EntourageManager.shared.user.gender == "other" {
                getButtonWith(tag: 100, view: self.view).selectedGenderBtn()
            }
            
        }

        
    }
}


// MARK: - Actions
extension GenderSelectionVC{
    
    @IBAction func pressGenderBtn(_ sender: UIButton) {
        
        if flow == true{
            
            if UserDefaults.standard.bool(forKey: "GenderChange") == false{
                UserDefaults.standard.set(true, forKey: "GenderChange" )
            }
            
        }
        
        //change the state of selected btn
        sender.selectedGenderBtn()
        if sender.tag == 98 {
            EntourageManager.shared.user.gender = "female"
        }else if sender.tag == 99{
            EntourageManager.shared.user.gender = "male"
        }else if sender.tag == 100{
            EntourageManager.shared.user.gender = "other"
        }
        
        //unSelect the Selected Previous Btn
        for index in 98...100{
            if index !=  sender.tag{
             getButtonWith(tag: index, view: self.view).unSelectGender()
            }
        }
        
        // enable continue button
        continueBtn.backgroundColor = Colors.themeColor.value
        vcTitleLbl.textColor = .black
        continueBtn.isUserInteractionEnabled = true
        
    }
    
    @IBAction func continueBtnPressed(_ sender: UIButton) {
        continueFeedBackBtn(.soft)
        if flow == true{
            WebServicesManager.shared.editUserProfile(checkAge: false ) { (response, error) in
                if error == nil{
                    self.navigationController?.popViewController(animated: true)
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }
        }else{
            self.loadAddFirstNameVC(vcType: false)
        }
    }

}

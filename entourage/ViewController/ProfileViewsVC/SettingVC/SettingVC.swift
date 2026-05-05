//
//  SettingVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/19/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import MultiSlider
import FirebaseAuth

class SettingVC: BaseVC {
    
    
    //MARK: - IBOutLets
    @IBOutlet weak var distanceSlider: CenteredThumbSlider!
    @IBOutlet weak var ageRangeLabel: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var phoneNumLbl: UILabel!
    @IBOutlet weak var appBuildVersion: UILabel!
    @IBOutlet weak var eliteStatausView: UIView!
    @IBOutlet weak var spotlightView: UIView!
    @IBOutlet weak var filterLbl: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var myGenderLbl: UILabel!
    @IBOutlet weak var blockMemberCount: UILabel!
    @IBOutlet var multiSlider: MultiSlider!
    
    //MARK:- Class Properties
    var cardView : UIView?
    var setting = EntourageManager.shared.setting
    var user = EntourageManager.shared.user
    var settingsChange = false
    let preSettings : Setting = EntourageManager.shared.setting!.copy()
    let preGender = EntourageManager.shared.user.gender ?? ""
        
    override func setupGUI() {
        super.setupGUI()
        
        title = "Settings"
        
        self.setUpNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!]
        
        //NavBar shadow
        //addNavBarShadow()
        self.navigationController?.navigationBar.setSettingNavBarShadow()

        setUpNavBarButton()
        
        if let text = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            appBuildVersion.text = "Build \(text)"
        }

        for state: UIControl.State in [.normal, .selected, .application, .reserved] {
            distanceSlider.setThumbImage(UIImage(named: "oval") , for: state)
        }

        
    }
    
    override func updateGUI() {
        self.showNavBar()
        
        Utils.currVC = self

        self.setting = EntourageManager.shared.setting
        
        self.setUpView()
        
    }
        
    
    fileprivate func setUpNavBarButton(){
        let barBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(pressDoneBtn))
        barBtn.setTitleTextAttributes([NSAttributedString.Key.font : UIFont(name: "Avenir-Medium", size: 17)!,
                                       NSAttributedString.Key.foregroundColor:UIColor(named: "themeColor") as Any], for: .normal)
        navigationItem.rightBarButtonItem = barBtn
    }
    
    fileprivate func setUpView(){

        user.gender = user.gender ?? "" == "female" ? "Female" : user.gender//TODO From Server Side
        myGenderLbl.text = "\(user.gender ?? "")".capitalizingFirstLetter()
        
        if setting?.everyone ?? false == true {
            filterLbl.text = "Everyone"
        }else if setting?.female_only ?? false == true{
            filterLbl.text = "Females"
        }else if setting?.male_only ?? false == true{
            filterLbl.text = "Males"
        }else{

            if user.gender == "male"{
                filterLbl.text = "Females"
            }else if user.gender == "female"{
                filterLbl.text = "Males"
            }else{
                filterLbl.text = "Everyone"
            }
            
        }
        
        phoneNumLbl.text = user.phone_number ?? ""
        
        multiSlider.minimumValue = 18
        multiSlider.maximumValue = 70
        
        multiSlider.value = [CGFloat(setting?.min_age ?? 18) , CGFloat((setting?.max_age ?? 42)) ]
        multiSlider.outerTrackColor = UIColor("#b5b5b6")
        multiSlider.orientation = .horizontal
        multiSlider.hasRoundTrackEnds = true

        
        distanceSlider.minimumValue = 1
        distanceSlider.maximumValue = 100
        distanceSlider.value = Float(setting?.max_distace ?? 50)
        distanceLabel.text = "\(setting?.max_distace ?? 50) mi"
        
        //distanceSlider.trackRect(forBounds: CGRect(x: 0, y: 0, width: CGFloat(self.view.frame.width - (24+22)), height: 3))
        
        multiSlider.thumbImage = distanceSlider.currentThumbImage ?? UIImage()
        multiSlider.showsThumbImageShadow = false
        
        ageRangeLabel.text = "\(setting?.min_age ?? 18)-\(setting?.max_age ?? 42)"
        blockMemberCount.text = "\(setting?.block_member_count ?? 0)"
        
    }
    
    fileprivate func genderAlert(){
        
        let alert = UIAlertController(title: "Contact Support", message: "You can only change your Gender once in-app. Please contact us if you need to change it again.", preferredStyle: UIAlertController.Style.alert)
        
        let option1 = UIAlertAction(title: "Close", style: UIAlertAction.Style.default, handler: nil)
        let option2 = UIAlertAction(title: "Contact Us", style: .default) { (action) in
                openBrowserWith(url: "https://www.entourage-app.com/support.html")
        }
        
        alert.addAction(option1)
        alert.addAction(option2)

        self.present(alert, animated: true, completion: nil)

    }
}


// MARK: - Actions
extension SettingVC{
    
    @objc func pressDoneBtn(){
        
        if Setting.checkSettingUpdateion(previousGender: preGender, preSetting: preSettings, NewSetting: self.setting!) {//Settings is Update then Api is Call
            
            self.startAnimation()
            WebServicesManager.shared.updateSettings { (response, error) in
                self.stopAnimation()
                if error == nil{
                    //self.showAlert(title: "Settings", message: "Update successfully")
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }

        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func pressPremiumBtn(_ sender: Any) {
        //self.loadPremiumVC()
        
    }

    @IBAction func pressManageNotificationBtn(_ sender: Any) {
        //self.loadPremiumVC()
        let vc = ManageNotificationVC.manageNotificationVC()
        self.navigationController?.show(vc, sender: nil)
    }

    @IBAction func pressEditProfileBtn(_ sender: Any) {
        self.loadUserProfileVC(user: EntourageManager.shared.user, group: nil )
    }
    
    
    @IBAction func pressShowMeBtn(_ sender: UIButton) {
        self.navigationController?.pushViewController(FiltersVC.loadFiltersVC(), animated: true)
    }
    
    @IBAction func pressChangeGender(_ sender: UISwitch) {
                
        if UserDefaults.standard.bool(forKey: "GenderChange") == true{
            self.genderAlert()
        }else{
            let vc = GenderSelectionVC.genderSelectedVC(flow: true)
            self.navigationController?.show(vc, sender: nil)
        }
        
    }
    
    @IBAction func ageSliderChange(_ sender: MultiSlider) {
        ageRangeLabel.text = "\(Int(sender.value.min()!))-\(Int(sender.value.max()!))"
        
        EntourageManager.shared.setting?.min_age = Int(sender.value.min()!)
        EntourageManager.shared.setting?.max_age = Int(sender.value.max()!)
        
        self.setting = EntourageManager.shared.setting

        Utils.updateMyGroup = true
        
    }
    
    @IBAction func groupSliderChange(_ sender: UISlider) {
        EntourageManager.shared.setting?.group_member_count = Int(sender.value)
        self.setting = EntourageManager.shared.setting
    }
    
    
    @IBAction func spotLightBtn(_ sender: UIButton) {
        
    }
    
    @IBAction func locationBtn(_ sender: Any) {
        
    }
    
    @IBAction func blockedUsersBtn(_ sender: Any) {
        self.navigationController?.pushViewController(BlockedUserVC.blockedUserVC(), animated: true)
    }

    @IBAction func distanceSliderChange(_ sender: UISlider) {
        self.distanceLabel.text = "\(Int(sender.value)) mi"
        EntourageManager.shared.setting?.max_distace = Int(sender.value)
        self.setting = EntourageManager.shared.setting
    }
    
    @IBAction func logoutBtnPressed(_ sender: UIButton) {
        
        let vc = LogoutVC.logoutVC {
                        
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }

            Utils.switchToOnBoarding()
        }
        
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func deleteAccountBtn(_ sender: UIButton) {
        
        self.show(DeleteAccountVC.deleteAccountVC(), sender: nil)
        
    }
    
    @IBAction func privacyPolicyBtnPressed(_ sender: UIButton) {
        loadExtrenal(url: "https://www.entourage-app.com/privacy-policy.php")
    }
    
    @IBAction func termsAndConditionBtnPressed(_ sender: UIButton) {
        loadExtrenal(url: "https://www.entourage-app.com/terms-of-service.php")
    }
    
    @IBAction func supportBtnPressed(_ sender: UIButton) {
        loadExtrenal(url: "https://www.entourage-app.com/support.php")
    }
    
    @IBAction func suggestionBtnPressed(_ sender: UIButton) {
        loadExtrenal(url: "https://entourage.upvoty.com/b/feature-requests/")
    }
}

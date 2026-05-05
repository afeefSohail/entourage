//
//  FilterDialogue.swift
//  entourage
//
//  Created by MAC on 07/03/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit
import MultiSlider

class FilterDialogueVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet var multiSlider: MultiSlider!
    @IBOutlet weak var ageRangeLabel: UILabel!

    @IBOutlet weak var distanceSlider: CenteredThumbSlider!
    @IBOutlet weak var distanceLabel: UILabel!
    

    //MARK:- Class Properties
    var setting = EntourageManager.shared.setting
    var user = EntourageManager.shared.user
    var settingsChange = false
    let preSettings = EntourageManager.shared.setting!.copy()
    let preGender = EntourageManager.shared.user.gender ?? ""
    var callback : PressOkay!
    
    //MARK: - Constructor
    class func loadFilterDialogueVC(callback:@escaping PressOkay)->FilterDialogueVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let filterDialogueVC = storyboard.instantiateViewController(withIdentifier: "FilterDialogueVC") as! FilterDialogueVC
        
        filterDialogueVC.callback = callback
        
        return filterDialogueVC
    }

    override func setupGUI() {
        super.setupGUI()
        
        for state: UIControl.State in [.normal, .selected, .application, .reserved] {
            distanceSlider.setThumbImage(UIImage(named: "oval") , for: state)
        }

    }

    override func updateGUI() {
        super.updateGUI()
        
        setUpView()
    }
    
    
    fileprivate func setUpView(){

        distanceSlider.minimumValue = 1
        distanceSlider.maximumValue = 100
        distanceSlider.value = Float(setting?.max_distace ?? 50)
        distanceLabel.text = "\(setting?.max_distace ?? 50) mi"
        
        distanceSlider.trackRect(forBounds: CGRect(x: 0, y: 0, width: CGFloat(self.view.frame.width - (48+48)), height: 3))
        
        multiSlider.minimumValue = 18
        multiSlider.maximumValue = 70
        
        multiSlider.value = [CGFloat(setting?.min_age ?? 18) , CGFloat((setting?.max_age ?? 42)) ]
        multiSlider.outerTrackColor = UIColor("#b5b5b6")
        multiSlider.orientation = .horizontal
        multiSlider.hasRoundTrackEnds = true

        multiSlider.thumbImage = distanceSlider.currentThumbImage ?? UIImage()
        multiSlider.showsThumbImageShadow = false
        
        ageRangeLabel.text = "\(setting?.min_age ?? 18)-\(setting?.max_age ?? 42)"
    }

    @IBAction func pressDoneBtn(_ sender: Any){
        
        if Setting.checkSettingUpdateion(previousGender: preGender, preSetting: preSettings, NewSetting: self.setting!) {//Settings is Update then Api is Call
                        
            self.startAnimation()
            WebServicesManager.shared.updateSettings { (response, error) in
                self.stopAnimation()
                if error == nil{
                    
                    self.callback()
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.showAlert(title: "Error", message: error!)
                }
            }

        }else{
            self.dismiss(animated: true, completion: nil)
        }
        
    }

    @IBAction func ageSliderChange(_ sender: MultiSlider) {
        ageRangeLabel.text = "\(Int(sender.value.min()!))-\(Int(sender.value.max()!))"
        
        setting?.min_age = Int(sender.value.min()!)
        setting?.max_age = Int(sender.value.max()!)
    }
    
    @IBAction func distanceSliderChange(_ sender: UISlider) {
        self.distanceLabel.text = "\(Int(sender.value)) mi"
        setting?.max_distace = Int(sender.value)
    }

}

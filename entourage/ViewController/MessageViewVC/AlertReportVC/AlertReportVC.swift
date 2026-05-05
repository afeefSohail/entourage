//
//  AlertReportVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class AlertReportVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var titleLbl : UILabel!

    //MARK: - class Properties
    var reportedUserName : String = ""
    var reportedGroup : Group = Group()
    var callback:PressOkay!
    
    //MARK: - Class Properties
    override func setupGUI() {
        super.setupGUI()
        
        self.titleLbl.text = reportedUserName
        
    }

    @IBAction func pressConfirmBtn(sender:UIButton){
        self.dismiss(animated: true) {
            self.callback()
        }
    }
}

//
//  SMSDialogueVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class SMSDialogueVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var mainMessageLabel: UILabel!
    @IBOutlet weak var previewMessageLabel: UILabel!
    
    //MARK:- Class Properties
    var callback : PressOkay!
    let selectedFriendsList = [String]()
    
    
    override func setupGUI() {
        super.setupGUI()
        
        
    }

    @IBAction func pressCancelBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pressOkBtn(_ sender: Any) {
        self.dismiss(animated: true) {
            self.callback()
        }
    }
    
}

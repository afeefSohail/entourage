//
//  GroupUnMatchVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/21/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class GroupUnMatchVC: BaseVC {
    
    var callback : PressOkay!
        
        override func setupGUI() {
            
        }
        
        override func updateGUI() {
            
        }
    
    @IBAction func pressConfirm(sender:Any){
        self.dismiss(animated: true) {
            self.callback()
        }
    }

}

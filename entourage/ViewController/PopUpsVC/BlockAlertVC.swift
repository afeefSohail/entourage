//
//  BlockAlertVC.swift
//  entourage
//
//  Created by MAC on 27/02/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class BlockAlertVC: BaseVC {

    //MARK: - IBOutLets
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var blockStatusBtn : UIButton!
    
    //MARK:- Class Properties
    var callback : PressOkay!
    var bockedUser = ""
    var btnTitle = "Block"
    

    //MARK:- Class Methods
    override func setupGUI() {
    
        
    }
    
    

}

//MARK: - Actions
extension BlockAlertVC{
    
    @IBAction func pressRemove(sender:Any){
        
        self.callback()
        self.dismiss(animated: true, completion: nil)
    }

}

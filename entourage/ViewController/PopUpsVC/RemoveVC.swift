//
//  RemoveVC.swift
//  entourage
//
//  Created by afeef sohail on 1/24/20.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class RemoveVC: BaseVC {
    
    //MARK: - IBOutLets
    var callback : PressOkay!
    @IBOutlet weak var msgLbl: UILabel!

    var userName : String = ""
    //MARK: - Constructor
    class func loadRemoveVC(userName:String,callback:@escaping PressOkay)->RemoveVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let removeVC = storyboard.instantiateViewController(withIdentifier: "RemoveVC") as! RemoveVC
        
        removeVC.callback = callback
        removeVC.userName = userName
        
        return removeVC
    }
    
    override func setupGUI() {
        self.msgLbl.text = "Are you sure you want to remove \(userName) as a friend?"
    }
    
    override func updateGUI() {
        
    }
}


//MARK: - Actions
extension RemoveVC{
    
    @IBAction func pressRemove(sender:Any){
        
        self.callback()
        self.dismiss(animated: true, completion: nil)
    }
}

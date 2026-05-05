//
//  AlertReportUserVC.swift
//  entourage
//
//  Created by afeef sohail on 04/07/2021.
//  Copyright © 2021 West Bay Technologies. All rights reserved.
//

import UIKit

func convertTo(url:String)->URL?{
    if let url = URL(string: url){
        return url
    }
    
    return nil
}

class AlertReportUserVC: BaseVC {
    
    //MARK:- IBOutLets
    @IBOutlet weak var userIV : UIImageView!
    @IBOutlet weak var userNameLbl : UILabel!
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var msgIV : UIImageView!
    @IBOutlet weak var confirmBtn : UIButton!

    //MARK:- Class Properties
    var callback:PressOkay!
    lazy var msgImage : UIImage = UIImage()
    lazy var user : User = User()
    lazy var report:Bool = true

    //AMRK: - Class Methods
    override func setupGUI() {
        setUpView()
    }

    
    fileprivate func setUpView(){
        
        if let url = convertTo(url: user.getPrimaryImageThumb()){
            setupThumnail(url: url, IV: userIV)
        }
        
        msgIV.image = msgImage.af_imageAspectScaled(toFit: msgIV.frame.size)
        
        titleLbl.text = report ? "Report User Content" : "Block User"
        userNameLbl.text = user.user_name
        
        setUpConfirmBtn()
    }
    
    fileprivate func setUpConfirmBtn(){
        let btnColor = report ? UIColor("#FF9100") : UIColor("#F02424")
        confirmBtn.setTitleColor(btnColor, for: .normal)
    }
    
    
    fileprivate func reportUser(){
        
        self.startAnimation()
        WebServicesManager.shared.reportUser(user: user, reason: "Abusive content", image: msgImage) { (reponse, error) in
            self.stopAnimation()
            if error == nil{
                self.dismiss(animated: true) {
                    self.callback()
                }
            }else{
                self.showAlert(title: "Error", message: error!)
            }
            
        }
    }
    
    fileprivate func blockUser(){
        
        self.startAnimation()
        WebServicesManager.shared.blockFriend(frendId: user.id,reason: "Abusive content.",abusiveMsg: msgImage) { (reponse, error) in
            self.stopAnimation()
            if error == nil{
                self.dismiss(animated: true) {
                    self.callback()
                }
            }else{
                self.showAlert(title: "Error", message: error!)
            }
        }
    }
}

extension AlertReportUserVC {
    
    @IBAction func pressConfirmBtn(sender:UIButton){
        report ? reportUser() : blockUser()
    }
}

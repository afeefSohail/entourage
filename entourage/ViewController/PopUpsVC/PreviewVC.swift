//
//  PreviewVC.swift
//  entourage
//
//  Created by MAC on 28/02/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class PreviewVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var contentView : UIView!
    @IBOutlet weak var titleLbl : UILabel!
    @IBOutlet weak var preViewTypeImage : UIImageView!
    @IBOutlet weak var continueBtn : UIButton!
    @IBOutlet weak var descLbl1 : UILabel!
    @IBOutlet weak var descLbl2 : UILabel!
    @IBOutlet weak var breakLine : UIView!

    
    
    //MARK:- Class Properties
    var callback : PressOkay!
    var previewType = ""
    
    //MARK: - Constructor
    class func loadPreviewVC(previewType:String, callback:@escaping PressOkay)->PreviewVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let previewVC = storyboard.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        
        previewVC.callback = callback
        previewVC.previewType = previewType
        
        return previewVC
    }
    
    //MARK:- Class Methods
    override func setupGUI() {
        
        contentView.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width - CGFloat(58) , height: contentView.frame.height)
        
        contentView.threeColorGradient(colorOne: UIColor("#fcfcff"), colorTwo: UIColor("#f6f8f9"), colorThree: UIColor("#f5f7f9"))
        
        setUpView()
    }
    
    fileprivate func setUpView(){
        
        breakLine.frame =  CGRect(x: 0, y: 0, width: self.view.frame.width - CGFloat(58) , height: 3)

        if previewType == "iMatch"{
            
            breakLine.horizentalGradient(colorOne: UIColor("#00ebff"), colorTwo: UIColor("#00c0e3"),cornerRdaius: 0)
            titleLbl.text = "INSTAMATCH"
            titleLbl.textColor = Colors.themeColor.value
            descLbl1.text = "Try Matching Instantly?"
            descLbl2.text = "No need for them to Swipe back."
            continueBtn.setImage(UIImage(named: "iMatchContinue"), for: .normal)
            preViewTypeImage.image = UIImage(named: "fire2")

        }else{
           
            breakLine.horizentalGradient(colorOne: UIColor("#6c62ff"), colorTwo: UIColor("#0f02d1"),cornerRdaius: 0)
            titleLbl.text = "SPOTLIGHT"
            titleLbl.textColor = UIColor("#4033ff")
            descLbl1.text = "Try Group Boost?"
            descLbl2.text = "Get 10x the matches for 30 minutes."
            continueBtn.setImage(UIImage(named: "spotLiteContinue"), for: .normal)
            preViewTypeImage.image = UIImage(named: "diamond")

        }
    }
    
}

//MARK: - Actions
extension PreviewVC{
    
    @IBAction func pressContinue(sender:Any){
        
        self.callback()
        self.dismiss(animated: true, completion: nil)
    }

    
}

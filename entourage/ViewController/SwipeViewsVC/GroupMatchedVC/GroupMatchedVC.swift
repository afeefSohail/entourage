//
//  GroupMatchedVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/1/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class GroupMatchedVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var groupMemberName: UILabel!
    
    @IBOutlet weak var groupStatusName: UILabel!
    @IBOutlet weak var groupStatusImageName: UIImageView!


    @IBOutlet weak var firstImageView: UIView!
    @IBOutlet weak var secImageView: UIView!
    @IBOutlet weak var thirdImageView: UIView!
    @IBOutlet weak var fourthImageView: UIView!


    @IBOutlet weak var groupMemberViewHeight: NSLayoutConstraint!
    @IBOutlet weak var firstImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var thirdImageViewWidth: NSLayoutConstraint!
    @IBOutlet weak var fourthImageViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var secImageViewTrailMargin: NSLayoutConstraint!
    @IBOutlet weak var thirdImageViewTrailMargin: NSLayoutConstraint!
    @IBOutlet weak var fourthImageViewTrailMargin: NSLayoutConstraint!
    
    @IBOutlet weak var sendMsgBtn: UIButton!
    @IBOutlet weak var keepSwipeBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!

    
    //MARK:- Class Properties
    var myGroup = EntourageManager.shared.myGroup
    var matchType = ""
    var matchGroup : Group!
    var phoneNumbers : [String] = []
    var callback : PressOkay!
    
    override func setupGUI() {
        super.setupGUI()
    }
    
    override func updateGUI() {
        self.title = "Match"
        setUpView()
    }
    
    fileprivate func setUpView(){
        var otherGroupImages : [String] = []
        
        let interlinkImagePadding = 30
        var leftRightMarginSpace = 0
        
        if matchGroup.users.count == 3 || matchGroup.users.count == 4{
            leftRightMarginSpace = matchGroup.users.count == 3 ? 8 : 15
        }
        
        let imageWidth = ( Int(view.bounds.width) / matchGroup!.users.count ) + leftRightMarginSpace
        let imageHeigt = imageWidth

        groupMemberViewHeight.constant = CGFloat(imageHeigt)
        firstImageViewWidth.constant = CGFloat(imageWidth)
        thirdImageViewWidth.constant = CGFloat(imageWidth)
        fourthImageViewWidth.constant = CGFloat(imageWidth)
        
        secImageViewTrailMargin.constant = -CGFloat(interlinkImagePadding)
        thirdImageViewTrailMargin.constant = -CGFloat(interlinkImagePadding)
        fourthImageViewTrailMargin.constant = -CGFloat(interlinkImagePadding)

        //SetUpView According to MatchType
        if matchType == "instant"{
            titleImage.image = UIImage(named: "instantMatch")
            sendMsgBtn.setTitleColor(UIColor("#6c62ff"), for: .normal)
            backBtn.setImage(UIImage(named: "instantMatchBackBtn"), for: .normal)
            self.view.setGradientBackground(colorOne: UIColor("#4033ff"), colorTwo: UIColor("#6c62ff"))
        }else{
            titleImage.image = UIImage(named: "groupMatch")
            sendMsgBtn.setTitleColor(UIColor("#00d8ff"), for: .normal)
            backBtn.setImage(UIImage(named: "groupMatchBackBtn"), for: .normal)
            self.view.setGradientBackground(colorOne: UIColor("#00c1e3"), colorTwo: UIColor("#00d8ff"))
        }
        
        matchGroup?.users.forEach({otherGroupImages.append($0.getPrimaryImageOriginal())})
                
        if let url = URL(string:matchGroup?.groupStatus.icon ?? ""){
            groupStatusImageName.kf.indicatorType = .activity
            groupStatusImageName.kf.setImage(with: url)
        }
        
        groupStatusName.text = matchGroup?.groupStatus.name ?? ""
        groupMemberName.text = matchGroup?.matchGroupName()
        
        if (matchGroup.users.count == 2){
            
            thirdImageViewWidth.constant = 0
            fourthImageViewWidth.constant = 0
            thirdImageViewTrailMargin.constant = 0
            fourthImageViewTrailMargin.constant = 0

        }else if (matchGroup.users.count == 3) {
    
            fourthImageViewWidth.constant = 0
            fourthImageViewTrailMargin.constant = 0
        }

        
        for (index,value) in otherGroupImages.enumerated(){
            
            let newIndex = index + 1

            let image = getImageViewWith(tag: newIndex , view: self.view)
            image.backgroundColor = .white
            
            if let url = URL(string:value){
                image.kf.indicatorType = .activity
                //image.kf.setImage(with: url)
                setupThumnail(url: url, IV: image)
            }
             
            image.cornerRadius = CGFloat(imageHeigt / 2)
            image.borderWidth = 2
            image.borderColor = .white
        }
        
    }
    
    @IBAction func pressSendMessageBtn(_ sender: Any) {
        self.dismiss(animated: true) {
            self.callback()
        }
    }
    
    
    @IBAction func pressKeepSwipeBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}


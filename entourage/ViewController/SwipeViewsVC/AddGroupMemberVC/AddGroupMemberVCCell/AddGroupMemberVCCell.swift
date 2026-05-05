//
//  AddGroupMemberVCCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/1/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class AddGroupMemberVCCell: UITableViewCell {
    
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var checkImage: UIImageView!
    @IBOutlet weak var addBtnView: UIView!
    @IBOutlet weak var inviteView: UIView!
    @IBOutlet weak var innerViewImage: UIImageView!
    @IBOutlet weak var invitedBtn: UIButton!

    func setUpcell(friend:User?,inviteAccepted:String){
        titleLabel.text = "\(friend?.first_name ?? "") \(friend?.last_name ?? "")"
        userNameLbl.text = friend?.user_name ?? ""
        
        addBtnView.isHidden = false
        inviteView.isHidden = true
        
        let photo = friend?.photos.filter({$0.is_primary == true})
        
        if photo?.count ?? 0 > 0{
            if let url = URL(string: photo![0].medium ?? ""){
                userImageView.kf.indicatorType = .activity
               // userImageView.kf.setImage(with: url)
                setupThumnail(url: url, IV: userImageView)
            }
        }
        
        if friend?.isMember == true , inviteAccepted == "Yes"{
            
            addBtnView.isHidden = true
            inviteView.isHidden = false
            innerViewImage.image = UIImage(named: "inGroup")
            titleLabel.textColor = UIColor("#00c0e3")
            
            invitedBtn.isEnabled = false
        }else if friend?.isMember == false , inviteAccepted == "No"{
            //TODO:- when member is invited
            addBtnView.isHidden = true
            inviteView.isHidden = false
            innerViewImage.image = UIImage(named: "infoInvited")
            titleLabel.textColor = UIColor("#6c62ff")
            
            invitedBtn.isEnabled = true
        }else if friend?.isMember == false , inviteAccepted == "Selected"{
            checkImage.image =  UIImage(named: "activotyGroup")
            titleLabel.textColor = UIColor(named: "themeColor")
            
            invitedBtn.isEnabled = false
        }else{
            invitedBtn.isEnabled = false
            checkImage.image = UIImage(named: "selection_circle")
            titleLabel.textColor = UIColor.black
        }
        
    }
    
}

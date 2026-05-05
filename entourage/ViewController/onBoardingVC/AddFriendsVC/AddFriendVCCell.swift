//
//  AddFriendVCCell.swift
//  entourage
//
//  Created by afeef sohail on 12/7/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class AddFriendVCCell: UITableViewCell {

    @IBOutlet weak var nameInitialsLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var addBtn: UIButton!

    var contact : AllContacts!
    
    func cellSetUp(){
                
        if contact.reloationStatus == "match"{
            addBtn.layer.borderWidth = 0
            addBtn.setTitle("", for: .normal)
            //self.addBtn.setImage(UIImage(named: "friends"), for: .normal)
            self.addBtn.setImage(UIImage(named: "added"), for: .normal)
            addBtn.isEnabled = false
        }else if contact.isSelected == true {
            addBtn.layer.borderWidth = 0
            addBtn.setTitle("", for: .normal)
            self.addBtn.setImage(UIImage(named: "added"), for: .normal)
            addBtn.isEnabled = false
        }else if contact.reloationStatus == "Request"{
            self.addBtn.setImage(UIImage(named: "noRelation"), for: .normal)
            addBtn.layer.borderWidth = 0
            addBtn.setTitle("", for: .normal)
            addBtn.backgroundColor = .white
            addBtn.isEnabled = true
        }
        
        nameInitialsLbl.text = contact.nameIntials
        nameLbl.text = contact.userName
        
        nameInitialsLbl.isHidden = false
        profileImage.isHidden = false

        if let imageData = contact.avatarData{
            nameInitialsLbl.isHidden = true
            profileImage.contentMode = .scaleAspectFill
            profileImage.image = UIImage(data: imageData )
        }else if let url = URL(string: contact.imageUrl)  {
            
            nameInitialsLbl.isHidden = true
            profileImage.contentMode = .scaleAspectFill
            //profileImage.kf.setImage(with: url)
            setupThumnail(url: url, IV: profileImage)
        }else{
            profileImage.isHidden = true
            nameInitialsLbl.text = contact.nameIntials
        }
        
    }

}

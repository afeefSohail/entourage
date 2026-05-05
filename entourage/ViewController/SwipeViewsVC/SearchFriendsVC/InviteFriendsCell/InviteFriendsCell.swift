//
//  InviteFriendsCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/31/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class InviteFriendsCell: UITableViewCell {
    
    @IBOutlet weak var inviteTitleLabel: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var cellBtn: UIButton!
    @IBOutlet weak var nameInitials: UILabel!
    @IBOutlet weak var contactBelongsToLbl: UILabel!

    var contact : PhoneContact!
    
    func cellSetUp(){
        
        inviteTitleLabel.text = contact.name ?? ""
        userNameLbl.text = contact.phoneNumber
        nameInitials.isHidden = false
        userImage.isHidden = false

        if let imageData = contact.avatarData{
            userImage.contentMode = .scaleToFill
            userImage.image = UIImage(data: imageData )
            nameInitials.isHidden = true
        }else{
            userImage.isHidden = true
            nameInitials.text = contact.nameIntials ?? ""
        }
        
    }
    
}

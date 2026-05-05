//
//  AvatarViewCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/27/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import MessageKit


class AvatarViewCell: UICollectionViewCell {
    
        @IBOutlet weak var participantIV: AvatarView!
        @IBOutlet weak var nameLbl: UILabel!
        
        
        func update(with participant:ChatUser){
            
            if participant.isAnonymous {
                self.nameLbl.text = "Anon"
                participantIV.image = UIImage(named: "icon-anonymous")
                participantIV.backgroundColor = .clear
                return
            }
            
            //name
            if let name = participant.firstName {
                
                if name == "" || participant.isAnonymous{
                    self.nameLbl.text = "Anon"
                } else {
                    self.participantIV.initials = Utils.initials(fromName: participant.displayName)
                    self.nameLbl.text = name
                }
            } else {
                self.nameLbl.text = "Anon"
            }
            
            //actual avatar
            if participant.photoUrl == "" || participant.isAnonymous {
                participantIV.image = UIImage(named: "icon-anonymous")
                participantIV.backgroundColor = .clear
            } else if participant.id == "100001"{
                //participantIV.sd_setImage(with: URL(string: participant.photoUrl))
                participantIV.image = UIImage(named: "group1")
            }else if participant.id == "100002"{
                participantIV.image = UIImage(named: "pending")
            }
        }
        

}

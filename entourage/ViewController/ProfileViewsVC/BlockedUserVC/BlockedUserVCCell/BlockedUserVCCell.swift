//
//  BlockedUserVCCell.swift
//  entourage
//
//  Created by afeef sohail on 11/2/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class BlockedUserVCCell: UITableViewCell {

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var checkImage: UIImageView!

    func setUpcell(friend:Friend?){
        titleLabel.text = friend?.first_name ?? ""
        userNameLbl.text = "@\(friend?.user_name ?? "")"
                
        let photo = friend?.photos.filter({$0.is_primary == true})
        
        if photo?.count ?? 0 > 0{
            if let url = URL(string: photo![0].medium ?? ""){
                userImageView.kf.indicatorType = .activity
                //userImageView.kf.setImage(with: url)
                setupThumnail(url: url, IV: userImageView)
            }
        }else{
            userImageView.image = UIImage(named: "defaultImg")!
        }
                
    }

}

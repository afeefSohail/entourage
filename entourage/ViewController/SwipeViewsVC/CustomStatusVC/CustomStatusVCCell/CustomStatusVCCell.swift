//
//  CustomStatusVCCell.swift
//  entourage
//
//  Created by afeef sohail on 1/5/20.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class CustomStatusVCCell: UICollectionViewCell {
 
    @IBOutlet weak var emojiImage : UIImageView!
    @IBOutlet weak var backView : UIView!

    func recentStatus(status:GroupStatuses){
        guard let url = URL(string: status.icon ?? "") else{
            return
        }
        emojiImage.kf.indicatorType = .activity
        emojiImage.kf.setImage(with: url)
    }
}


class SectionHeader: UICollectionReusableView {
    @IBOutlet weak var sectionHeaderlabel: UILabel!
}

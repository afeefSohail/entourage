//
//  OtherNotifcationCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit

class OtherNotifcationCell : SwipeTableViewCell {

    //MARK: - IBOutLets
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}

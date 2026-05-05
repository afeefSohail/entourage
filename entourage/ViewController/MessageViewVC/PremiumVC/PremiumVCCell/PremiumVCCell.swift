//
//  PremiumVCCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit

class PremiumVCCell: SwipeTableViewCell {

    @IBOutlet weak var featuredImageView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var leadingConstant: NSLayoutConstraint!
    
    @IBOutlet weak var descLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}

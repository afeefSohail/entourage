//
//  NewMatchCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class NewMatchCell: UITableViewCell {

    //MARK: - IBOutLets
    @IBOutlet weak var profileGroupImageView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newMessageStatus: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

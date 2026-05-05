//
//  RequestAcceptedCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class RequestAcceptedCell: UITableViewCell {

    //MARK: - IBOutLets
    @IBOutlet weak var initialLetters: UILabel!
    @IBOutlet weak var messageTitle: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}

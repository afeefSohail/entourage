//
//  TutorialVCCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/25/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class TutorialVCCell: UICollectionViewCell {
    
    //MARK: - IBOUTLets
    @IBOutlet weak var imageView: UIImageView!
        
    
    /// Enlarges the cell when false, shrinks when true.
    var isInBackground = true {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.autoResize()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layoutIfNeeded()
        autoResize()
    }
    
    /// Responsible for resizing the cell.
    private func autoResize() {
        switch self.isInBackground {
        case true:
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        case false:
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }

    
}

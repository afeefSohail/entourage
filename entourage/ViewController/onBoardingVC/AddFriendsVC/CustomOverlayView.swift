//
//  OverlayView.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/30/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Koloda

class SwipeOverlayView: OverlayView {
    
    
    @IBOutlet lazy var overlayImageleftView: UIImageView! = {
        [unowned self] in
        
            var imageView = UIImageView(frame: CGRect(x: 18, y: 41, width: 158, height: 65))
            self.addSubview(imageView)
            return imageView

        
        }()

    @IBOutlet lazy var overlayImageRightView: UIImageView! = {
        [unowned self] in
        
            var imageView = UIImageView(frame: CGRect(x: 18, y: 41, width: 158, height: 65))
            self.addSubview(imageView)
            return imageView

        
        }()

    override var overlayState: SwipeResultDirection?  {
        didSet {
            switch overlayState {
            case .left? :
                overlayImageRightView.image = nil
                overlayImageleftView.image = UIImage(named: "cardpass")
            case .right? :
                overlayImageleftView.image = nil
                overlayImageRightView.image = UIImage(named: "cardlike")
            default:
                overlayImageleftView.image = nil
                overlayImageRightView.image = nil
            }
            
        }
    }
    
}

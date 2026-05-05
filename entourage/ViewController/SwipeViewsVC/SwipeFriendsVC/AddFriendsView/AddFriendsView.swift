//
//  AddFriendsView.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/31/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class AddFriendsView: UIView {

    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var addFriendsBtn: UIButton!
    @IBOutlet weak var importFriendsBtn: UIButton!
    @IBOutlet weak var openAppLink: UIButton!

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        commonInit()
    }
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("AddFriendsView", owner: self , options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
    }

}

//
//  MyActivityIndicator.swift
//  entourage
//
//  Created by afeef sohail on 11/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class MyActivityIndicator: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var inidicator: UIActivityIndicatorView!
    
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
        
        Bundle.main.loadNibNamed("MYActivityIndicator", owner: self , options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
    }


}

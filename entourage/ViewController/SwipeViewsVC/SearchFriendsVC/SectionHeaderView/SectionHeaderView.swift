//
//  SectionHeaderView.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/31/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class SectionHeaderView: UIView {

    @IBOutlet var containterView: UIView!
    @IBOutlet weak var headerTitleLabel: UILabel!
    
    
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
        
        Bundle.main.loadNibNamed("SectionHeaderView", owner: self , options: nil)
        addSubview(containterView)
        containterView.frame = self.bounds
        containterView.autoresizingMask = [.flexibleHeight,.flexibleWidth]

        
    }


}

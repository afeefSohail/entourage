//
//  FourMember.swift
//  entourage
//
//  Created by afeef sohail on 10/1/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class FourMember: UIView {
    
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var firstImage: UIImageView!
    @IBOutlet weak var secondImage: UIImageView!
    @IBOutlet weak var thirdImage: UIImageView!
    @IBOutlet weak var fourImage: UIImageView!

    var senderId = 0
    
    init(frame: CGRect,senderId:Int) {
        super.init(frame: frame)
        self.senderId = senderId
        commonInit()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        commonInit()
    }
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("FourMember", owner: self , options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        setUpProfileView()
    }
    
    fileprivate func setUpProfileView(){
        
        if EntourageManager.shared.myGroup != nil,EntourageManager.shared.myGroup?.status == "active"{
            let myGroup = EntourageManager.shared.myGroup!
            var images : [String] = []
            
                myGroup.users.forEach({images.append($0.getPrimaryImageThumb())})

            for (index,value) in images.enumerated(){
                
                let image = getImageViewWith(tag: index+1 , view: self)
                
                if let url = URL(string:value){
                    image.contentMode = .scaleAspectFill
                    image.kf.indicatorType = .activity
                    image.kf.setImage(with: url)
                }
                
                if myGroup.users[index].id == senderId {
                    image.borderColor = Colors.themeColor.value
                }
            }

        }
    }
    
}

//
//  GroupCardViewOne.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/15/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class GroupCardViewOne: UIView {

    //MARK: - IBoutLets
    @IBOutlet var containterView: UIView!
    
    @IBOutlet weak var firstGroupMemberImage: UIImageView!
    @IBOutlet weak var secondMemberImage: UIImageView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    
    //MARK: - Properties
    var space : CGFloat = 0

    init(frame: CGRect,space:Int) {
        super.init(frame: frame)
        self.space = CGFloat(space)
        
        commonInit()
        //twoMemberGroup(group: group)
    }

    init(frame: CGRect,space:Int,group:Group) {
        super.init(frame: frame)
        self.space = CGFloat(space)
        
        commonInit()
        twoMemberGroup(group: group)
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        commonInit()
    }
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("GroupCardViewOne", owner: self , options: nil)
        addSubview(containterView)
        containterView.frame = self.bounds
        containterView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
     
        mainStackView.spacing = space
    }
    
    fileprivate func twoMemberGroup(group:Group){
        
        self.firstGroupMemberImage.image = UIImage(named: "defaultImg")
        if let url = URL(string: group.users.last?.getPrimaryImageThumb() ?? ""){
            firstGroupMemberImage.kf.indicatorType = .activity
            self.firstGroupMemberImage.kf.setImage(with: url)
        }
        
        self.secondMemberImage.image = UIImage(named: "defaultImg")
        if let url = URL(string: group.users.first?.getPrimaryImageThumb() ?? ""){
            secondMemberImage.kf.indicatorType = .activity
            self.secondMemberImage.kf.setImage(with: url)
        }
        
    }

}

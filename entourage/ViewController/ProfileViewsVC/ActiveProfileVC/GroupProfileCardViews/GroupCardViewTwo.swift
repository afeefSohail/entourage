//
//  GroupCardViewTwo.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/15/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

class GroupCardViewTwo: UIView {

    //MARK: - IBoutLets
    @IBOutlet var containterView: UIView!
    
    @IBOutlet weak var firstGroupMemberImage: UIImageView!
    @IBOutlet weak var secondMemberImageView: UIImageView!
    @IBOutlet weak var thirdMemberImageView: UIImageView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var stackViewOne: UIStackView!
    
    //MARK: - Properties
    var space : CGFloat = 0
    
    init(frame: CGRect,space:Int) {
        super.init(frame: frame)
        
        self.space = CGFloat(space)
        commonInit()
        //threeMemberGroup(group: group)
    }
    
    init(frame: CGRect,space:Int,group:Group) {
        super.init(frame: frame)
        self.space = CGFloat(space)
        
        commonInit()
        threeMemberGroup(group: group)
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        commonInit()
    }
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("GroupCardViewTwo", owner: self , options: nil)
        addSubview(containterView)
        containterView.frame = self.bounds
        containterView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        mainStackView.spacing = space
        stackViewOne.spacing = space

    }


    fileprivate func threeMemberGroup(group:Group){
        self.firstGroupMemberImage.image = UIImage(named: "defaultImg")
        if let url = URL(string: group.users.last?.getPrimaryImageThumb() ?? ""){
            firstGroupMemberImage.kf.indicatorType = .activity
            self.firstGroupMemberImage.kf.setImage(with: url)
        }
        
        self.thirdMemberImageView.image = UIImage(named: "defaultImg")
        if let url = URL(string: group.users[1].getPrimaryImageThumb()){
            thirdMemberImageView.kf.indicatorType = .activity
            self.thirdMemberImageView.kf.setImage(with: url)
        }

        self.secondMemberImageView.image = UIImage(named: "defaultImg")
        if let url = URL(string: group.users[0].getPrimaryImageThumb()){
            secondMemberImageView.kf.indicatorType = .activity
            self.secondMemberImageView.kf.setImage(with: url)
        }
        
    }

}

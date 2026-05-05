//
//  CardView.swift
//  entourage
//
//  Created by afeef sohail on 8/4/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Kingfisher

class SwipeCards : UIView {
    
    //MARK: - IBoutLets
    @IBOutlet var containterView: UIView!
    @IBOutlet weak var secStackView: UIView!
    @IBOutlet weak var groupNameLbl: UILabel!
    
    @IBOutlet weak var firstGroupMemberImage: UIImageView!
    @IBOutlet weak var firstGroupMemberLabel: UILabel!
    
    @IBOutlet weak var fourMemberImageView: UIImageView!
    @IBOutlet weak var fourMemberLabel: UILabel!
    
    @IBOutlet weak var secondMemberView: UIView!
    @IBOutlet weak var secondMemberImageView: UIImageView!
    @IBOutlet weak var secondMemberLabel: UILabel!
    
    @IBOutlet weak var thirdMemberImageView: UIImageView!
    @IBOutlet weak var thirdMemberLabel: UILabel!
    
    //@IBOutlet weak var groupType: UILabel!
    @IBOutlet weak var AddressLabel: UILabel!
    @IBOutlet weak var groupStatusImage: UIImageView!
    @IBOutlet weak var groupMemberIcon : UIImageView!
    @IBOutlet weak var activeStatus: UILabel!
    
    @IBOutlet weak var firstMemberBtn: UIButton!
    @IBOutlet weak var secondMemberBtn: UIButton!
    @IBOutlet weak var thirdMemberBtn: UIButton!
    @IBOutlet weak var fourMemberBtn: UIButton!

    @IBOutlet weak var reportBtn: UIButton!

    init(frame: CGRect,group:Group) {
        super.init(frame: frame)
        commonInit()
        self.setUpCardView(group:group)
        
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
        
        commonInit()
    }
    
    private func commonInit(){
        
        Bundle.main.loadNibNamed("MoreMemberSwipeCard", owner: self , options: nil)
        addSubview(containterView)
        containterView.frame = self.bounds
        containterView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
    }
    
    fileprivate func setUpCardView(group:Group){
        
        guard let url = URL(string: group.groupStatus.icon ?? "") else{
            return
        }
        
        groupStatusImage.kf.setImage(with: url)
        activeStatus.text = (group.groupStatus.name ?? "")
        activeStatus.textColor = group.groupStatus.statusType == "place" ? UIColor("#6c62ff") : UIColor.black
        AddressLabel.text = "\(group.distance ?? "")".capitalized
        groupNameLbl.text = group.cardsGroupName()
        
        groupMemberIcon.image = UIImage(named: group.getGroupIconName())
        
        if group.users.count > 0{
            if group.users.count == 3{
                ThreeMemberGroup(group: group)
            }else if group.users.count == 2{
                TwoMemberGroup(group: group)
            }else{
                fourMemberGroup(group: group)
            }
        }
        
    }
    
    fileprivate func ThreeMemberGroup(group:Group){
        self.secondMemberView.isHidden = true
        
        self.firstGroupMemberLabel.text = "\(group.users.last?.user_name ?? ""), \(group.users.last?.age ?? 0)"
        if let url = URL(string: group.users.last?.getPrimaryImageOriginal() ?? ""){
            //firstGroupMemberImage.contentMode = .scaleAspectFit
            //firstGroupMemberImage.kf.setImage(with: url)
            setupThumnail(url:url , IV: firstGroupMemberImage)
        }
        
        self.thirdMemberLabel.text = "\(group.users[0].user_name ?? ""), \(group.users[0].age ?? 0)"
        if let url = URL(string: group.users[0].getPrimaryImageOriginal() ){
            //thirdMemberImageView.kf.setImage(with: url)
            setupThumnail(url:url , IV: thirdMemberImageView)
        }
        
        self.fourMemberLabel.text = "\(group.users[1].user_name ?? ""), \(group.users[1].age ?? 0)"
        if let url = URL(string: group.users[1].getPrimaryImageOriginal() ){
            //fourMemberImageView.kf.setImage(with: url)
            setupThumnail(url:url , IV: fourMemberImageView)
        }
        
        
    }
    
    fileprivate func TwoMemberGroup(group:Group){
        self.secStackView.isHidden = true
        
        self.firstGroupMemberLabel.text = "\(group.users.last?.user_name ?? ""), \(group.users.last?.age ?? 0)"
        if let url = URL(string: group.users.last?.getPrimaryImageOriginal() ?? ""){
            //firstGroupMemberImage.kf.setImage(with: url)
            setupThumnail(url:url , IV: firstGroupMemberImage)
        }
        
        self.secondMemberLabel.text = "\(group.users.first?.user_name ?? ""), \(group.users.first?.age ?? 0)"
        if let url = URL(string: group.users.first?.getPrimaryImageOriginal() ?? ""){
            //secondMemberImageView.kf.setImage(with: url)
            setupThumnail(url:url , IV: secondMemberImageView)
        }

    }
    
    fileprivate func fourMemberGroup(group:Group){
        
        self.firstGroupMemberLabel.text = "\(group.users.last?.user_name ?? ""), \(group.users.last?.age ?? 0)"
        if let url = URL(string: group.users.last?.getPrimaryImageOriginal() ?? ""){
            //firstGroupMemberImage.kf.setImage(with: url)
            setupThumnail(url:url , IV: firstGroupMemberImage)

        }
        
        self.secondMemberLabel.text = "\(group.users[0].user_name ?? ""), \(group.users[0].age ?? 0)"
        if let url = URL(string: group.users[0].getPrimaryImageOriginal()){
            //secondMemberImageView.kf.setImage(with: url)
            setupThumnail(url:url , IV: secondMemberImageView)
        }
        
        self.thirdMemberLabel.text = "\(group.users[1].user_name ?? ""), \(group.users[1].age ?? 0)"
        if let url = URL(string: group.users[1].getPrimaryImageOriginal() ){
            //thirdMemberImageView.kf.setImage(with: url)
            setupThumnail(url:url , IV: thirdMemberImageView)
        }
        
        self.fourMemberLabel.text = "\(group.users[2].user_name ?? ""), \(group.users[2].age ?? 0)"
        if let url = URL(string: group.users[2].getPrimaryImageOriginal() ){
            //fourMemberImageView.kf.setImage(with: url)
            setupThumnail(url:url , IV: fourMemberImageView)
        }
        
    }
    
    
}

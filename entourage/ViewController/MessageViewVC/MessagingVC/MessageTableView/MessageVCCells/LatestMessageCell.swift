//
//  latestMessageCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import SwipeCellKit

class LatestMessageCell: SwipeTableViewCell {
    
    //MARK: - IBOutLet
    @IBOutlet weak var profileGroupImageView: UIImageView!
    @IBOutlet weak var secMemberImage: UIImageView!
    @IBOutlet weak var thirdMemberImage: UIImageView!
    @IBOutlet weak var fourthMemberImage: UIImageView!
    @IBOutlet weak var msgIcon: UIImageView!

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var newMessageStatus: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var replyIconWidth: NSLayoutConstraint!
    @IBOutlet weak var replyIconHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUpCell(match:Match,index:Int){
        
        title.text = match.matcher?.matcherGroupName()
        
        descriptionLabel.font = UIFont(name: "Avenir-Medium", size: 16)
        descriptionLabel.textColor = UIColor("#666666")
        replyIconWidth.constant = 0
        replyIconHeight.constant = 0

        let userId = EntourageManager.shared.user.id
        let chatId = "Match_\(match.chat_id)"
        //let myMessage = getMyMsg(id: chatId)
        let groupLastMessage = getLastMsg(id:chatId)
        let senderId = getLastSender(key: chatId)
        var sender : User?
        
        //find user from My Group of From Match Group
        if let matchUser = match.matcher?.users.last(where: {$0.id == senderId}){
            sender = matchUser
        }else if let groupUser = EntourageManager.shared.myGroup?.users.last(where: {$0.id == senderId}){
            sender = groupUser
        }
                
        for (index) in 0..<4{
            
            if match.matcher?.users.indices.contains(index) ?? false{
                
                if index == 0{
                    self.setUpUserPhoto(user: match.matcher!.users[0], imageView: profileGroupImageView)
                }else if index == 1{
                    self.setUpUserPhoto(user: match.matcher!.users[1], imageView: secMemberImage)
                }else if index == 2{
                    self.setUpUserPhoto(user: match.matcher!.users[2], imageView: thirdMemberImage)
                }else{
                    self.setUpUserPhoto(user: match.matcher!.users[3], imageView: fourthMemberImage)
                }

            }else{

                if index == 1{
                    secMemberImage.isHidden = true
                }else if index == 2{
                    thirdMemberImage.isHidden = true
                }else{
                    fourthMemberImage.isHidden = true
                }

            }
            
        }
        
        
        newMessageStatus.isHidden = getUnReadMsg(id: chatId ) > 0 ? false : true

        if  /*myMessage.isEmpty,*/ groupLastMessage.isEmpty {

            replyIconWidth.constant = 16
            replyIconHeight.constant = 16
            msgIcon.image = UIImage(systemName:"paperplane.fill")

            descriptionLabel.font = UIFont(name: "Avenir-Medium", size: 16)
            descriptionLabel.textColor = Colors.themeColor.value
            descriptionLabel.text = "  Send a Message"

        }else if getLastSender(key: chatId) == userId{
            
            replyIconWidth.constant = 12
            replyIconHeight.constant = 8
            descriptionLabel.text = "  \(groupLastMessage)"
            msgIcon.image = UIImage(named: "replyIcon")
            
        }else {
            descriptionLabel.text = groupLastMessage
        }
                
    }
    
    
    fileprivate func setUpUserPhoto(user:User,imageView:UIImageView){
        
        let photo = user.photos.filter({$0.is_primary == true})
        
        if photo.count > 0{
            if let url = URL(string: photo[0].medium ?? ""){
                imageView.kf.indicatorType = .activity
//                imageView.kf.setImage(with: url)
                setupThumnail(url: url, IV: imageView)
            }
            
        }else{
            imageView.image = UIImage(named: "defaultImg")
        }
        
    }

}

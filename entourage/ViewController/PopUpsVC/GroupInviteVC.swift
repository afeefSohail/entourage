//
//  GroupInviteVC.swift
//  entourage
//
//  Created by afeef sohail on 10/13/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit


class GroupInviteVC: BaseVC {

    
    //MARK: - IBOutLets
    @IBOutlet weak var mainLbl : UILabel!
    
    var userName = EntourageManager.shared.user.name()
    var group = EntourageManager.shared.myGroup
    var invitGroup : Group?
    var invitedGroupId : Int = 0
    var callback : inviteGroup!
    
    //MARK: - Constructor
    class func groupInviteVC(groupInvitedId:Int,callback:@escaping inviteGroup)->GroupInviteVC{
        
        let storyboard = UIStoryboard(name: "Alerts", bundle: nil)
        let groupInviteVC = storyboard.instantiateViewController(withIdentifier: "GroupInviteVC") as! GroupInviteVC
        
        groupInviteVC.invitedGroupId = groupInvitedId
        groupInviteVC.callback = callback
        return groupInviteVC
    }
    
    override func setupGUI() {
        
        
        if let invitedGroup = EntourageManager.shared.groupInviteRequestes.last(where: {$0.id == invitedGroupId}){
           
            var name = NSMutableAttributedString()
            var message = NSMutableAttributedString()

            if let _ = group{
                
                name = NSMutableAttributedString(string: "\(invitedGroup.users.last?.name() ?? "") ", attributes: [NSAttributedString.Key.foregroundColor : Colors.themeColor.value , NSAttributedString.Key.font : UIFont(name: "Avenir-Medium" , size: 16)! ])
                
                message = NSMutableAttributedString(string: " has invited you to her group, joining their group will force you to leave your current." , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#B3B3B3"), NSAttributedString.Key.font : UIFont(name: "Avenir-Book" , size: 16)! ])

            }else{
                
                name = NSMutableAttributedString(string: "\(invitedGroup.users.last?.name() ?? "") ", attributes: [NSAttributedString.Key.foregroundColor : Colors.themeColor.value , NSAttributedString.Key.font : UIFont(name: "Avenir-Medium" , size: 16)! ])
                
                message = NSMutableAttributedString(string: "has invited you to her group." , attributes: [NSAttributedString.Key.foregroundColor : UIColor("#B3B3B3"), NSAttributedString.Key.font : UIFont(name: "Avenir-Book" , size: 16)! ])

            }
        
            
            let nameWithAge = NSMutableAttributedString(attributedString: name)
            
            nameWithAge.append(message)
            mainLbl.attributedText = nameWithAge

            invitGroup = invitedGroup
            setUpImages()
        }
        
    }

    override func updateGUI() {
        
    }

    fileprivate func setUpImages(){
        var imagesGroup1 : [String] = []
        
        var imagesGroup2 : [String] = []
        

        invitGroup?.users.forEach({imagesGroup2.append($0.getPrimaryImageThumb())})


        if let _ = group{
            group?.users.forEach({imagesGroup1.append($0.getPrimaryImageThumb())})
        }else{
            imagesGroup1.append(EntourageManager.shared.user.getPrimaryImageThumb())
        }

        for index in 0...2{

            if index+1 <= imagesGroup1.count{
                
                let image = getImageViewWith(tag: (index+1)+3 , view: self.view)
                self.setUpImages(images: imagesGroup1, index: index, image: image)
                
            }else{
                let view = getViewWith(tag: (index+1), view: self.view)
                view.isHidden = true
            }

        
        }

        for index in 0...2{

            if index+1 <= imagesGroup2.count{
                
                let image = getImageViewWith(tag: (index+7)+3 , view: self.view)
                self.setUpImages(images: imagesGroup2, index: index, image: image)
                
            }else{
                let view = getViewWith(tag: (index+7), view: self.view)
                view.isHidden = true
            }

        }
        
    }

    fileprivate func setUpImages(images:[String], index:Int, image:UIImageView){
        
        if index+1 <= images.count{

            if let url = URL(string:images[index]){
                image.kf.indicatorType = .activity
                //image.kf.setImage(with: url)
                setupThumnail(url: url, IV: image)
            }
        }else{
            let view = getViewWith(tag: (index+1), view: self.view)
            view.isHidden = true
        }

    }
    
//    fileprivate func deleteTheDocument(groupId:String,completetion:@escaping()->Void){
//        lastMessageListner?.delete(docId: groupId , completion: { (error) in
//            if error != nil{
//                self.showAlert(title: "Error", message: error!.localizedDescription)
//            }else{
//            
//                let totalMatch = EntourageManager.shared.myMatchs.count
//                self.deleteMatchTheDocument(index: 0, matchCount: totalMatch)
//                
//                completetion()
//            
//            }
//            
//        })
//    }
//
//    fileprivate func deleteMatchTheDocument(index:Int,matchCount:Int){
//        
//        if index >= matchCount{
//            EntourageManager.shared.myMatchs = []
//            lastMessageListner?.unsubscribe()
//            self.stopAnimation()
//            return
//        }
//
//        lastMessageListner?.delete(docId: "Match_\(EntourageManager.shared.myMatchs[index].id)" , completion: { (error) in
//            if error != nil{
//                self.stopAnimation()
//                self.showAlert(title: "Error", message: error!.localizedDescription)
//                return
//            }else{
//                self.deleteMatchTheDocument(index:index+1, matchCount: matchCount)
//            }
//        })
//    
//    }

    
    fileprivate func restObjects(){

        resetAllUnReadMsg()
        
        EntourageManager.shared.myGroup = nil
        self.callback(true)
        self.dismiss(animated: true, completion: nil)
    }

}

//MARK: - IBActions
extension GroupInviteVC{
    
    @IBAction func confirmBtn(_ sender:UIButton){
        
        let previousGroup = self.group
        
        self.startAnimation()
        WebServicesManager.shared.acceptGroupInvite(groupId: invitGroup?.id ?? 0) { (response, error) in
            if error == nil{
                
                if previousGroup?.users.count ?? 0 == 2{
                    //remove Group
                    deleteTheDocument(groupId: "\(previousGroup?.id ?? 0)", completetion: {


                        EntourageManager.shared.reSetAppData()

                        EntourageManager.shared.user.saveToken()
                        
                        self.restObjects()
                        
                        self.stopAnimation()
                    })
                }else{
                    
                    EntourageManager.shared.reSetAppData()

                    EntourageManager.shared.user.saveToken()

                    self.restObjects()
                    
                    self.stopAnimation()
                }

                
                self.dismiss(animated: true, completion: nil)
                self.callback(true)

            }else{
                self.dismiss(animated: true, completion: nil)
                self.showAlert(title: "Error", message: error!)
                self.callback(false)

            }
        }
    }
    
    @IBAction func cancelBtn(_ sender:UIButton){
        
        WebServicesManager.shared.rejectGroupInvite(groupId: invitGroup?.id ?? 0) { (response, error) in
            if error == nil{
                
                self.dismiss(animated: true, completion: nil)
                self.callback(false)

            }else{
                self.dismiss(animated: true, completion: nil)
                self.showAlert(title: "Error", message: error!)
                self.callback(false)
            }
        }

    }

    
}

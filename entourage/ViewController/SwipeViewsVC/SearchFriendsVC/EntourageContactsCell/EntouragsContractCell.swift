//
//  EntouragsContractCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/31/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
//import SwipeCellKit


class EntouragsContractCell: UITableViewCell{ //SwipeTableViewCell  {
    
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var cellBtn: UIButton!
    @IBOutlet weak var cellBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var contactBelongsToLbl: UILabel!
    @IBOutlet weak var nameInitials: UILabel!
    
    var friend = Friend()
    var vc = SearchFriendsVC()
    var cellInSection = 0
    var btnCount = [0,0]
    
    //MARK: - All Friends Users
    
    func friendCell(vc : SearchFriendsVC,section:Int){
        self.vc = vc
        var status = self.friend.status ?? ""
        status.capitalizeFirstLetter()
        
        //Defualt State for Every Cell
        userImage.isHidden = false
        cellBtn.isHidden = false
        cellBtn.isEnabled = true

        firstNameLbl.text = self.friend.first_name ?? "N/A"
        userNameLbl.text = self.friend.user_name ?? "\(self.friend.phone_number ?? "")"
        contactBelongsToLbl.text = self.friend.contactType ?? ""
        cellBtnWidth.constant = 60
        cellBtn.removeTarget(nil, action: nil, for: .touchUpInside)

        if status == "Match"{
            
            cellBtn.setImage(UIImage(named:"friends"), for: .normal)
            cellBtn.isHidden = false
            cellBtn.addTarget(self, action: #selector(pressConvertRemobeBtn(sender:)) , for:    .touchUpInside)
            
        }else if status == "Remove"{
            
            cellBtn.isHidden = false
            cellBtn.setImage(UIImage(named:"remove"), for: .normal)
            cellBtn.addTarget(self, action: #selector(pressUnfriendBtn(sender:)) , for:    .touchUpInside)
        
        }
        
        setUpUserPhoto()
    }
    
    //MARK: - Accepted or Requested Users Relations
    
    func requestCell(vc : SearchFriendsVC,section:Int){
        
        self.vc = vc
        var status = self.friend.status ?? ""
        status.capitalizeFirstLetter()
        
        //Defualt State for Every Cell
        userImage.isHidden = false
        cellBtn.isHidden = false
        cellBtn.isEnabled = true

        firstNameLbl.text = self.friend.first_name ?? "N/A"
        userNameLbl.text = self.friend.user_name ?? ""
        contactBelongsToLbl.text = self.friend.contactType ?? ""
        cellBtnWidth.constant = 60
        cellBtn.removeTarget(nil, action: nil, for: .touchUpInside)

        if status == "Accept"{
            
            cellBtn.setImage(UIImage(named:"request"), for: .normal)
            cellBtn.addTarget(self, action: #selector(pressAcceptBtn(sender:))  , for:    .touchUpInside)
            cellBtn.isHidden = false
            cellBtn.isEnabled = true
            
        }else if status == "Requested"{
            
            cellBtn.setImage(UIImage(named:"requested"), for: .normal)
            cellBtn.isHidden = false
            cellBtn.isEnabled = false
        
        }
        setUpUserPhoto()
    }
    
    //MARK: - Users Withought Relations
    func appContactCell(vc : SearchFriendsVC,section:Int){
        self.vc = vc
        var status = self.friend.status ?? ""
        status.capitalizeFirstLetter()
        
        //Defualt State for Every Cell
        userImage.isHidden = false
        cellBtn.isHidden = false
        cellBtn.isEnabled = true

        firstNameLbl.text = self.friend.first_name ?? "N/A"
        userNameLbl.text = self.friend.user_name ?? ""
        contactBelongsToLbl.text = self.friend.contactType ?? ""
        cellBtnWidth.constant = 60
        cellBtn.removeTarget(nil, action: nil, for: .touchUpInside)

        if status == "No_relation" {
            
            cellBtn.addTarget(self, action: #selector(pressRequestBtn(sender:)) , for:    .touchUpInside)
            cellBtn.backgroundColor = .white
            cellBtn.isHidden = false
            cellBtn.isEnabled = true
            cellBtn.setImage(UIImage(named:"noRelation"), for: .normal)
        
        }else if status == "Requested"{
        
            cellBtn.setImage(UIImage(named:"requested"), for: .normal)
            cellBtn.isHidden = false
            cellBtn.isEnabled = false
        
        }
        
        setUpUserPhoto()
    }
    
    //MARK: - Search Users
    func cellSetUp( vc : SearchFriendsVC,section:Int){
        
        let status = self.friend.status ?? ""
        
        switch status {
        
        case "match" :
            friendCell(vc: vc, section: section)
        case "accept":
            requestCell(vc: vc, section: section)
        case "no_relation":
            appContactCell(vc: vc, section: section)
        case "requested":
            appContactCell(vc: vc, section: section)
        default:
            appContactCell(vc: vc, section: section)
        }
        
    }
        
    //MARK: - setUp  User Photos
    fileprivate func setUpUserPhoto(){
        
        let photo = friend.photos.filter({$0.is_primary == true})
        
        if photo.count > 0{
            
            nameInitials.isHidden = true
            if let url = URL(string: photo[0].medium ?? ""){
                userImage.kf.indicatorType = .activity
                //userImage.kf.setImage(with: url)
                setupThumnail(url: url, IV: userImage)
            }else{
                nameInitials.isHidden = false
                nameInitials.text = friend.nameInitials()
                userImage.image = UIImage(named: "defaultImg")
            }
            
        }else{
            nameInitials.isHidden = false
            nameInitials.text = friend.nameInitials()
            userImage.image = UIImage(named: "defaultImg")
        }
        
    }
 
}


// MARK: - Actions
extension EntouragsContractCell{
    
    @objc func pressConvertRemobeBtn(sender:UIButton){
        
        if self.vc.tabType == ListType.Search.rawValue{
            self.vc.searchContacts[sender.tag].status = "remove"
        }else{
            self.vc.allFriends[sender.tag].status = "remove"
        }
        
        self.vc.tableView.reloadData()

    }
    
    @objc func pressUnfriendBtn(sender:UIButton){
        
        let id = self.friend.id
        let removeVC =  RemoveVC.loadRemoveVC(userName: self.friend.user_name ?? ""){
            
            self.vc.startAnimation()
            WebServicesManager.shared.unFriend(frendId: id) { (reponse, error) in
                self.vc.stopAnimation()
                if error == nil{
                    
                    
                    if let userIndex = EntourageManager.shared.FriendShips.lastIndex(where: {$0.id == id}){//remove Friend from User Friend List
                        EntourageManager.shared.FriendShips.remove(at: userIndex)
                    }

                    if let userIndex = RecentUsers.getSavedRecentUsers()?.lastIndex(where: {$0.id == id}){//remove from RecentUsers list
                        RecentUsers.removeRecentUser(userIndex:userIndex)
                    }
                    
                    
                    if self.vc.tabType == ListType.Search.rawValue{
                        
                        self.friend.status = "no_relation"
                        self.vc.searchContacts.remove(at: sender.tag)
                        self.vc.tableView.reloadData()
                        
                    }else if self.vc.tabType == ListType.All.rawValue{ 
                        
                        self.friend.status = "no_relation"
                        self.vc.allFriends.remove(at: sender.tag)
                        self.vc.tableView.reloadData()
                        
                    }
                    
                    
                }else{
                    self.vc.showAlert(title: "Error", message: error!)
                }
            }
            
            
        }
        
        removeVC.modalPresentationStyle = .overCurrentContext
        vc.present(removeVC, animated: true, completion: nil)
        
    }
    
    @objc func pressRequestBtn(sender:UIButton){
        
        let id = self.friend.id
        
        vc.startAnimation()
        WebServicesManager.shared.sendRequest(frendId: id ) { (reponse, error) in
            self.vc.stopAnimation()
            if error == nil{
                
                if reponse != nil{
                    
                    
                    if self.vc.tabType == ListType.Search.rawValue{
                        self.vc.searchContacts[sender.tag].status = "requested"
                        self.vc.allRequests.append(self.vc.searchContacts[sender.tag])
                    }
                    
                    self.vc.tableView.reloadData()

                }
                
            }else{
                self.vc.showAlert(title: "Error", message: error!)
            }
        }
    }
    
    
    @objc func pressAcceptBtn(sender:UIButton){
        
        let id = self.friend.id
        
        vc.startAnimation()
        WebServicesManager.shared.acceptRequest(frendId: id ) { (reponse, error) in
            self.vc.stopAnimation()
            if error == nil{
                
                if reponse != nil{
                    
                    self.friend.status = "match"
                    self.vc.allFriends.append(self.friend)
                    EntourageManager.shared.FriendShips.append(self.friend)

                    if self.vc.tabType == ListType.Search.rawValue{
                        self.vc.searchContacts.remove(at: sender.tag)
                    }else{
                        self.vc.allRequests.remove(at: sender.tag)
                    }
                    
                    
                    self.vc.tableView.reloadData()
                }
                
            }else{
                self.vc.showAlert(title: "Error", message: error!)
            }
        }
        
    }
    
}

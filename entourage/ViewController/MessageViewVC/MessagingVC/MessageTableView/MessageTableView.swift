//
//  MessageTableView.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//


import UIKit
import SwipeCellKit

class MessageTableView: NSObject , UITableViewDataSource {
    
    var vc : MessagesVC!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return vc.matchList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let match = vc.matchList[indexPath.item]

        let cell = tableView.dequeueReusableCell(withIdentifier: "LatestMessageCell", for: indexPath) as! LatestMessageCell
                
        cell.delegate = self
        cell.setUpCell(match: match,index: indexPath.item)
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension MessageTableView : UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let match = vc.matchList[indexPath.item]
        

            decrementUnReadMsgCounter(value: getUnReadMsg(id: "Match_\(match.chat_id)") )
            resetUnReadMsg(id: "Match_\(match.chat_id)")
            
            Utils.mainVC?.upadteMessageIcon()

            vc.matchList = EntourageManager.shared.myMatchs
            vc.messageTableView.reloadData()
            vc.setUpTheMessageFlow()
        
        Utils.notificationInChatRoom = false
        
        //ChatMessage FireStore Referernce
        chatListener = MessageFirebaseService.createListener(id: "Match_\(match.chat_id)")
        
        //ChatMember Avtive Status FireStore Referernce
        activeMemberListner = ActiveMemberFireBaseService.creatActiveListner(id:"Match_\(match.chat_id)" )

        self.vc.loadChatGroupVC(matchId: match.chat_id, group: match.matcher! ) { (updateStatus) in
            if updateStatus == true{
                self.vc.UnMatch(groupId: match.matcher?.id ?? 0 , index: indexPath.item)
            }
        }
        
    }
    
}


// MARK: - SwipeTableViewCellDelegate
extension MessageTableView : SwipeTableViewCellDelegate{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        //set Orientation Direction
        guard orientation == .right else { return nil }
        
        //deletionAction
        let deleteAction = SwipeAction(style: .default, title: "Unmatch") { action, indexPath in
            let match = self.vc.matchList[indexPath.item]
            
            self.vc.loadGroupUnMatchVC {
                
                Utils.mainVC?.upadteMessageIcon()
                self.vc.UnMatch(groupId: match.matcher?.id ?? 0 , index: indexPath.item)
                
            }
        }
        
        // customize  ScoreCard the action appearance
        deleteAction.backgroundColor = UIColor("#F02424")
        deleteAction.textColor = UIColor.white
        
        return [deleteAction]
        
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.transitionStyle = .border
        return options
    }
    
    
}


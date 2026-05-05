//
//  ChatGroupVCCell.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/23/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import MessageKit
import Agrume

// MARK: - EditMenu Stuff
extension MessageCollectionViewCell {
    
    fileprivate var messagesCollectionView:MessagesCollectionView?{
        
        guard let collectionView = self.superview as? MessagesCollectionView else{
            return nil
        }
        
        return collectionView
    }
    
    fileprivate var message:MessageType?{
        
        guard let messagesCollectionView = self.messagesCollectionView else{
            return nil
        }
        
        guard let indexPath = messagesCollectionView.indexPath(for: self) else{
            
            return nil
        }
        
        let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView)
        
        return message
    }
    
    @objc fileprivate func replyButtonPressed(_ sender: Any){
        
        //get message
//        guard let message = self.message as? MKMessage else {
//            return
//        }
//        
//        print("replyButtonPressed" + String(describing: message))
        
        //do your stuff
    }
    
    @objc fileprivate func forwardButtonPressed(_ sender: Any){
        
        //get message
//        guard let message = self.message as? MKMessage else {
//            return
//        }
//
//        print("forwardButtonPressed" + String(describing: message))
        
        //do your stuff
    }
    
    @objc fileprivate func copyButtonPressed(_ sender: Any){
        
        //get message
//        guard let message = self.message as? MKMessage else {
//            return
//        }
//
//        UIPasteboard.general.string = message.innerMessage.messageData.text
//        print("copyButtonPressed" + String(describing: message))
        
    }
    
    
    @objc fileprivate func deleteButtonPressed(_ sender: Any){
        
        //get message
//        guard let message = self.message as? MKMessage else {
//            return
//        }
//
//        guard let roomvc = messagesCollectionView?.messagesDataSource as? RoomVC else {
//            print ("souldnt have happened")
//            return
//        }
//
//        let viewModel = roomvc.viewModel
//
//        //remove
//        viewModel?.removeMessage(message: message.innerMessage, completion: { (message, error) in
//
//            print("message deleted " + message.id)
//        })
        
    }
}


// MARK: - MessageCellDelegate
extension ChatGroupVC: MessageCellDelegate{
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        NSLog("didTapMessge pressed")
        
        guard let message = cell.message as? MKMessage else {
            return
        }
        
        switch message.kind {
        case .text( _):
        
            showUserProfileOrReport(senderId: Int(message.sender.senderId) ?? 0, reportMsgImage:getMsgCellView(view: cell))
            break
        case .photo(let photoItem):
            self.showMediaMessageFullscreen(mediaItem: photoItem)
        default:
            break
        }
        
    }
    
    fileprivate func showMediaMessageFullscreen(mediaItem:MediaItem){
        
        /// if we don't have a url, that means it's simply a pending message
        guard let url = mediaItem.url else {
            return
        }
        
        let agrume = Agrume.init(url: url)
        agrume.show(from: self)
        
    }
    
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        
        print("didTapCellTopLabel")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        
        print("didTapMessageTopLabel")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        
        print("didTapMessageBottomLabel")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        
        print("didTapAccessoryView")
    }
    
    func didSelectURL(_ url: URL){
        print("didSelectURL")
        
        UIApplication.shared.open(url, options: [:])
    }
    
    static func createJoinDirectMsgRoom(otherUser: ChatUser, vc: ChatGroupVC) {
        
    }
}

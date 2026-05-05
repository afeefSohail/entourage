//
//  ChatMessage.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/23/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

protocol Identifiable:  Codable {
    var id:String {get set}
}

//message type
enum ChatMessageType :String,Codable{
    
    case Text
    case Photo
    case Video
    case Unknown
    case URL
}


//message data
struct ChatMessageData:Codable {
    
    var type:ChatMessageType
    var text:String
    var mediaUrl:String = ""
    var mediaThumbnail:UIImage?
    var videoThumbnailURL:String?
    var messageIcon: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case mediaUrl
        case videoThumbnailURL
    }
    
    
    
}

//message type
enum ChatMessageEmoticon :Int, Codable{
    
    case Angry = 1
    case Haha = 2
    case Neutral = 3
    case Sad = 4
    case Stressed = 5
    case Tired = 6
    
    
    var description: String {
        //return code
        return String(describing: self)
    }
    
    var image:UIImage?{
        let name = self.description
        let imageName = "emo-"+name.lowercased()
        return UIImage(named: imageName)
    }
    
    var code:String{
        
        switch self {
        case .Angry:
            return "\u{1F621}"
        case .Haha:
            return "\u{1F604}"
        case .Neutral:
            //return "\u{1F610}"
            return ""
        case .Sad:
            return "\u{1F625}"
        case .Stressed:
            return "\u{1F61F}"
        case .Tired:
            return "\u{1F62B}"
        }
        
    }
}


//actual message struct
struct ChatMessage : Identifiable {
    
    var id: String = ""
    var createdAt:Double
//    var updatedAt:Double
//    var isDeleted:Bool? = false
//    var isAnonymous:Bool? = false
    var messageData:ChatMessageData
    var emoticon:ChatMessageEmoticon
    var sender:ChatUser
}


//message codable
extension ChatMessage:Codable{
    
    private enum CodingKeys: String, CodingKey {
        case createdAt
//        case updatedAt
//        case isDeleted
//        case isAnonymous
        case messageData
        case emoticon
        case sender
    }
}

// MARK: - Custom Initializers
extension ChatMessage{
    
    private init(kind: ChatMessageData, sender:ChatUser, emoticon:ChatMessageEmoticon) {
        self.id = UUID().uuidString
        self.messageData = kind
        self.sender = sender
        self.createdAt = Date().timeIntervalSince1970
//        self.updatedAt = Date().timeIntervalSince1970
//        self.isDeleted = false
//        self.isAnonymous = false
        self.emoticon = emoticon
    }
    
    
    init(text:String, sender:ChatUser, emoticon:ChatMessageEmoticon) {
        let data = ChatMessageData(type: .Text, text: text, mediaUrl: "", mediaThumbnail: nil, videoThumbnailURL: nil, messageIcon: "")
        self.init(kind: data, sender: sender, emoticon: emoticon)
    }
    
    init(photo:UIImage, sender:ChatUser, emoticon:ChatMessageEmoticon) {
        let data = ChatMessageData(type: .Photo, text: "", mediaUrl: "", mediaThumbnail: photo,videoThumbnailURL: nil, messageIcon: "")
        self.init(kind: data, sender: sender, emoticon: emoticon)
    }
    
    init(videoURL:String, videoThumbnail: UIImage, sender:ChatUser, emoticon:ChatMessageEmoticon) {
        let data = ChatMessageData(type: .Video, text: "", mediaUrl: videoURL, mediaThumbnail: videoThumbnail, videoThumbnailURL: nil, messageIcon: "")
        self.init(kind: data, sender: sender, emoticon: emoticon)
    }

}

/// An object that groups the metMKMessagef a messages/ChatGroup.
public struct ChatUser {
    
    
    /// Note: This value must be unique across all senders.
    public let id: String
    
    /// The display name of a sender.
    public let displayName: String
    
    /// The display name of a sender.
    public var photoUrl: String
    
    public var isAnonymous: Bool = false

    /// The sender belongs which groupId.
    public var groupId: Int = 0

    /// first name
    public var firstName: String?{
        
        get {
            guard let fname = displayName.components(separatedBy: " ").first else{
                return nil
            }
            return fname
        }
    }
    
    
    // MARK: - Intializers
    public init(id: String, displayName: String, photoUrl: String, isAnonymous: Bool = false , groupId:Int) {
        self.id = id
        self.displayName = displayName
        self.photoUrl = photoUrl
        self.isAnonymous = isAnonymous
        self.groupId = groupId
    }
}


/// codable
extension ChatUser:Codable{
    
    private enum CodingKeys: String, CodingKey {
        
        case id = "uid"
        case displayName = "name"
        case photoUrl = "photoUrl"
        case isAnonymous = "isAnonymous"
        case groupId = "group_Id"
        
    }
}



/// Message representation in MessageKit
/// We cant subclass PCMessage so we are using containment pattern
/// sender property is confflicting so another reason for containement pattern
class MKMessage {
    
    //innier message
    public var innerMessage:ChatMessage
        
    //default init
    init(message:ChatMessage) {
        self.innerMessage = message
    }
}

/// MessageKit Protcol
extension MKMessage : MessageType{
    
    var sender: SenderType {
        let tempName = self.innerMessage.sender.displayName
        let id = self.innerMessage.sender.id
        return Sender(senderId: id, displayName: tempName)
    }
    
    var isAnonymous: Bool {
        return self.innerMessage.sender.isAnonymous
    }
    
    var senderAvatarURL: String {
        return self.innerMessage.sender.photoUrl
    }
    
    var messageId: String {
        return self.innerMessage.id
    }
    
    var sentDate: Date {
        return Date(timeIntervalSince1970: self.innerMessage.createdAt)
    }
    
//    var deleted: Bool{
//        return self.innerMessage.isDeleted!
//    }
    
    var isEmoticonMessage: Bool{
        return (self.innerMessage.messageData.text.count == 0) && (self.innerMessage.emoticon.image != nil)
    }
    
    var isFromCurrentUser: Bool{
        return self.sender.senderId == "\(EntourageManager.shared.user.id)"
    }
    
    var kind: MessageKind {
        
        if self.innerMessage.messageData.type == .Photo {
            if let thumbnail = self.innerMessage.messageData.mediaThumbnail{
                return .photo(MKMediaMessage(image: thumbnail))
            }
            return .photo(MKMediaMessage.init(url: innerMessage.messageData.mediaUrl))
        }
        
        if self.innerMessage.messageData.type == .Video {
            return .photo(MKMediaMessage.init(url: innerMessage.messageData.mediaUrl))
        }
        
        //text message but no lenght so we display the mode
        if isEmoticonMessage {
            return .photo(MKMediaMessage.init(image: self.innerMessage.emoticon.image!))
        }
        
        //else its text messages
        return .text(self.innerMessage.messageData.text)
    }
}

// MARK: - MKMessage Equality
extension MKMessage: Equatable , Comparable {
    
    /// Two Message are considered equal if they have the same id.
    public static func == (left: MKMessage, right: MKMessage) -> Bool {
        return left.messageId == right.messageId
    }
    
    //sorted
    static func < (lhs: MKMessage, rhs: MKMessage) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
}

/// MessageKit Protcol
struct MKMediaMessage : MediaItem{
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
    init(url: String){
        self.url = URL(string: url)
        self.image = UIImage()
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
}



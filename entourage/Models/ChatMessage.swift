//
//  ChatMessage.swift
//  entourage
//
//  Created by Furqan Ahmad on 6/23/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import UIKit

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




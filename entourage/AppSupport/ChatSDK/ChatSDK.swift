//
//  ChatSDK.swift
//  entourage
//
//  Created by afeef sohail on 9/19/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

class ChatSDK{
    
    /// Convert firebse object to actual model VIA Codable
    ///
    /// - Parameter documentChanges: firebase document changes
    /// - Returns: parsed objects
    static func decodeElements<ChatMessage:Codable>(from documentChanges:[DocumentChange]) -> [ChatMessage]{
        
        let elements = documentChanges.compactMap({ (diff) -> ChatMessage? in
            do {
                let element = try diff.document.data(as: ChatMessage.self)
            
                //let element = try FirestoreDecoder().decode(ChatMessage.self, from: data)
                
                //set id
                if var identifiable = element as? Identifiable {
                    identifiable.id = diff.document.documentID
                    return (identifiable as! ChatMessage)
                }
                
                return element
            }catch (let error){
                NSLog("Error decoding object \(error)")
                print(error.localizedDescription)
                return nil
            }
        })
        
        return elements
    }
    
    /// Decode one object from data
    ///
    /// - Parameter data: data
    /// - Returns: object
    static func decodeElement<ChatMessage:Codable>(from data:[String:Any]) -> ChatMessage?{
        
        do {
//          let message = try FirestoreDecoder().decode(ChatMessage.self, from: data)
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let message  = try JSONDecoder().decode(ChatMessage.self, from: jsonData)
            
            return message
        }catch (let error){
            print(error.localizedDescription)
            return nil
        }
    }
    
    /// Converts model object to the data
    ///
    /// - Parameter element: element
    /// - Returns: data
    static func encodeElement<ChatMessage:Codable>(from element:ChatMessage) -> [String:Any]{
        
        do {
            return try Firestore.Encoder().encode(element)
        } catch {
            print("Error encoding element: \(error)")
            return [:]
        }
//        let docData = try! FirestoreEncoder().encode(element)
//        return docData
    }
}


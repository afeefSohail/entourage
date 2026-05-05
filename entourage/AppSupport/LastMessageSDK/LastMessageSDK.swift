//
//  LastMessageSDK.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import CodableFirebase
import Firebase

class LastMessageSDK{
    
    /// Convert firebse object to actual model VIA Codable
    ///
    /// - Parameter documentChanges: firebase document changes
    /// - Returns: parsed objects
    static func decodeElements<LastMessage:Codable>(from documentChanges:[DocumentChange]) -> [LastMessage]{
        
        let elements = documentChanges.compactMap({ (diff) -> LastMessage? in
            do {
                let data = diff.document.data()
                let element = try FirestoreDecoder().decode(LastMessage.self, from: data)
                
                //                //set id
                //                if var identifiable = element as? Identifiable {
                //                    identifiable.id = diff.document.documentID
                //                    return (identifiable as! LastMessage)
                //                }
                
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
    static func decodeElement<LastMessage:Codable>(from data:[String:Any]) -> LastMessage?{
        
        do {
            let message = try FirestoreDecoder().decode(LastMessage.self, from: data)
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
    static func encodeElement<LastMessage:Codable>(from element:LastMessage) -> [String:Any]{
        
        let docData = try! FirestoreEncoder().encode(element)
        return docData
    }
}

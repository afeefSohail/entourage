//
//  ActiveMemberSDK.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import CodableFirebase
import Firebase

class ActiveMemberSDK{
    
    /// Convert firebse object to actual model VIA Codable
    ///
    /// - Parameter documentChanges: firebase document changes
    /// - Returns: parsed objects
    static func decodeElements<ActiveMember:Codable>(from documentChanges:[DocumentChange]) -> [ActiveMember]{
        
        let elements = documentChanges.compactMap({ (diff) -> ActiveMember? in
            do {
                
                let data = diff.document.data()
                let element = try FirestoreDecoder().decode(ActiveMember.self, from: data)
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
    static func decodeElement<ActiveMember:Codable>(from data:[String:Any]) -> ActiveMember?{
        
        do {
            let message = try FirestoreDecoder().decode(ActiveMember.self, from: data)
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
    static func encodeElement<ActiveMember:Codable>(from element:ActiveMember) -> [String:Any]{
        
        let docData = try! FirestoreEncoder().encode(element)
        return docData
    }

}

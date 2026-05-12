 //
//  FirebaseService.swift
//  entourage
//
//  Created by afeef sohail on 9/20/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import Firebase
import UIKit

/// This will talk to firebase and send and recieve model classes from firebase
class MessageFirebaseService<ChatMessage:Codable>{
    
    private let firestoreCollectionRef:CollectionReference
    private var listener:ListenerRegistration?
    private var query:Query

    //pagination
    private var lastVisiable:DocumentSnapshot?
    
    //init
    init(collectionRef:CollectionReference, query:Query) {
        self.firestoreCollectionRef = collectionRef
        self.query = query
    }
    
   static func createListener(id:String) -> MessageFirebaseService<ChatMessage>{
        let path = "Message/" + "\(id)" + "/ChatMessages"
        let collection = db.collection(path)
        let query = collection.order(by: "createdAt", descending: false)
        
        return MessageFirebaseService<ChatMessage>(collectionRef: collection, query: query)
    }
    
}

// MARK: - ChatStaff
extension MessageFirebaseService{
    
    /// Pull records in pagination form
    ///
    /// - Parameters:
    ///   - pageSize: size of the page
    ///   - completion: retruns the results when done
    public func fetch(pageSize:Int,completion:@escaping ([ChatMessage]) -> Void, callCompletionIfEmptyResult:Bool = false){
        
        //fetch
        self.fetchQuery(pageSize: pageSize).getDocuments { (querySnapshot, error) in
            
            //if no data
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            //objects
            let changes = snapshot.documentChanges
            let objects =  self.parseObjects(from: changes)
            if objects.count > 0 {
                completion(objects)
            } else if callCompletionIfEmptyResult {
                completion([])
            }
            // Note: we need the callback called in the failure case as well
            //completion(objects)
        }
    }
    
    /// Add the instsance to same path as query
    ///
    /// - Parameters:
    ///   - element: element to saved
    ///   - completion: callback for completion
    public func add(element:ChatMessage, completion:@escaping (ChatMessage,Error?) -> Void){
        
        let data = ChatSDK.encodeElement(from: element)
        self.firestoreCollectionRef.addDocument(data: data) { error in
            
            completion(element,error)
        }
    }
    
    
    /// Returns auto document id for the new document
    public func autoDocumentId() -> DocumentReference {
        return self.firestoreCollectionRef.document()
    }
    
    /// Updates one specific object in collection
    ///
    /// - Parameters:
    ///   - element: element
    ///   - completion: callback for completion
    public func addChatMessage(docId:String,element:ChatMessage, completion:@escaping (ChatMessage,Error?) -> Void){
        
        let data = ChatSDK.encodeElement(from: element)
        let docRef = self.firestoreCollectionRef.document(docId)
        docRef.setData(data) { error in
            completion(element,error)
        }
    }
    
    /// Deletes the specific element from the collection
    ///
    /// - Parameters:
    ///   - docId: document id
    ///   - completion: callback for completion
    public func delete(docId:String, completion:@escaping (Error?) -> Void){
        
        let docRef = self.firestoreCollectionRef.document(docId)
        docRef.delete { error in
            completion(error)
        }
    }
    
    /// Gets one specific object in collection
    ///
    /// - Parameters:
    ///   - element: element
    ///   - completion: callback for completion
    public func fetch(docId:String, completion:@escaping (ChatMessage?,Error?) -> Void){
        
        let docRef = self.firestoreCollectionRef.document(docId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                //decode
                guard let element:ChatMessage = ChatSDK.decodeElement(from: document.data()!) else{
                    
                    completion(nil,error)
                    return
                }
                
                //success
                completion(element,nil)
            } else {
                completion(nil,error)
            }
        }
    }
    
    /// Construct the query based on page size and last record
    ///
    /// - Parameters:
    ///   - pageSize: size of the page
    /// - Returns: updated Query
    private func fetchQuery(pageSize:Int = 1)->Query{
        
        //if this is first page
        guard let last = self.lastVisiable else {
            return self.query.limit(to: pageSize)
        }
        
        //we have a previous record
        return self.query.limit(to: pageSize).start(afterDocument: last)
    }
    
    /// Subscrive  changes
    ///
    /// - Parameters:
    ///   - added: added callback
    ///   - modified: modified callback
    ///   - removed: removed callback
    public func subscribeForUpdates(limit:Int? = 1, added:@escaping ([ChatMessage]) -> Void){
        
        self.listener = self.query.limit(to: limit!).addSnapshotListener(includeMetadataChanges: true, listener: { (querySnapshot, error) in
            
//        }) addSnapshotListener{ (querySnapshot, error) in
            
            //if no data
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            //added
            let addedChanges = snapshot.documentChanges.filter{ $0.type == .added }
            let addedObjects =  self.parseObjects(from: addedChanges)
            
            if addedObjects.count > 0 {
                added(addedObjects)
            }
            
        })
    }

    
    /// stop listening to message form this room
    public func unsubscribe(){
        
        guard let registration = self.listener else{
            return
        }
        
        registration.remove()
    }
    
    /// Converts rooms data to rooms
    ///
    /// - Parameter documentChanges: document changes
    /// - Returns: parsed ChatRoom
    fileprivate func parseObjects(from documentChanges:[DocumentChange]) -> [ChatMessage]{
        let messages = ChatSDK.decodeElements(from: documentChanges) as [ChatMessage]
        
        return messages
    }

    

}



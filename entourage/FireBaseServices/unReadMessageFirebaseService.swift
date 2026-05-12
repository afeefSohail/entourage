//
//  unReadMessageFirebaseService.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import Firebase

/// This will talk to firebase and send and recieve model classes from firebase
class unReadMessageFirebaseService<LastMessage:Codable>{
    
    private let firestoreCollectionRef:CollectionReference
    private var listener:ListenerRegistration?
    private var query:Query
    
    //pagination
    private var lastVisiable:DocumentSnapshot?
    
    var Matches = EntourageManager.shared.myMatchs
    var myGroup = EntourageManager.shared.myGroup!
    
    //init
    init(collectionRef:CollectionReference, query:Query) {
        self.firestoreCollectionRef = collectionRef
        self.query = query
    }
    
    static func matchListener() -> unReadMessageFirebaseService<LastMessage>{
        let path = "Message/"
        let collection = db.collection(path)
        let myGroupId = EntourageManager.shared.myGroup!.id
        
        let query = collection.whereField("groupIds", arrayContains: myGroupId  )
        
        return unReadMessageFirebaseService<LastMessage>(collectionRef: collection, query: query)
    }
    
}



// MARK: - MessageRoom
extension unReadMessageFirebaseService{
    
    /// Pull records in pagination form
    ///
    /// - Parameters:
    ///   - pageSize: size of the page
    ///   - completion: retruns the results when done
    public func fetch(pageSize:Int,completion:@escaping ([LastMessage]) -> Void, callCompletionIfEmptyResult:Bool = false){
        
        //fetch
        self.fetchQuery(pageSize: pageSize).getDocuments { (querySnapshot, error) in
            
            //if no data
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            //objects
            let changes = snapshot.documentChanges
            let objects =  self.parseObjectsMessage(from: changes)
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
    public func add(element:LastMessage, completion:@escaping (LastMessage,Error?) -> Void){
        
        let data = LastMessageSDK.encodeElement(from: element)
        self.firestoreCollectionRef.addDocument(data: data) { error in
            
            completion(element,error)
        }
    }
    
    
    /// Returns auto document id for the new document
    public func autoDocumentId() -> DocumentReference {
        return self.firestoreCollectionRef.document()
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
    public func fetch(docId:String, completion:@escaping (LastMessage?,Error?) -> Void){
        
        let docRef = self.firestoreCollectionRef.document(docId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                //decode
                guard let element:LastMessage = LastMessageSDK.decodeElement(from: document.data()!) else{
                    
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
    private func fetchQuery(pageSize:Int = 100)->Query{
        
        //if this is first page
        guard let last = self.lastVisiable else {
            return self.query.limit(to: pageSize)
        }
        
        //we have a previous record
        return self.query.limit(to: pageSize).start(afterDocument: last)
    }
    
    
    //addListner for lastMessage in Match
    public func lastMesssageUpdates(limit:Int? = 1, completion:@escaping (String,Error?) -> Void){
        
        self.listener = self.query.limit(to: limit!).addSnapshotListener { (querySnapshot, error) in

            //if no data
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                completion("",error)
                return
            }



            snapshot.documentChanges.forEach({ (doc) in


                let last = doc.document.get("lastMessage") as? String ?? ""

                switch doc.type {
                case .added:

                    let myChatCounter = doc.document.get("user_\(EntourageManager.shared.user.id)") as? Int ?? 0

                    print("\(myChatCounter)--added-->last msg",doc.document.documentID)

                    self.checkLastMessageReadStatus(doc:doc, completion: {
                        completion(last,error)
                    })

                case .modified:
                    let myChatCounter = doc.document.get("user_\(EntourageManager.shared.user.id)") as? Int ?? 0

                    print("\(myChatCounter)--modified-->last msg",doc.document.documentID)

                    self.checkLastMessageReadStatus(doc:doc, completion: {
                        completion(last,error)
                    })

                case .removed:
                    break
                default:
                    break
                }

            })

            completion("",error)
        }
        
    }
    
    /// stop listening to message form this room
    public func unsubscribe(){
        
        guard let registration = self.listener else{
            return
        }
        
        registration.remove()
        lastMessageListner = nil
    }
    
    
    /// Updates one specific object in collection
    ///
    /// - Parameters:
    ///   - element: element
    ///   - completion: callback for completion
    public func updateLastMessage(docId:String, userReadCounter : Int, element:LastMessage, createdAt: Date ,completion:@escaping (LastMessage,Error?) -> Void){
        
        var data = LastMessageSDK.encodeElement(from: element)
        //add new properties
        
        
        let docRef = self.firestoreCollectionRef.document(docId)
        data["user_\(EntourageManager.shared.user.id)"] = userReadCounter
        data["createdAt"] = createdAt.timeIntervalSince1970
        
        let mergeFields : [Any] = ["chatTotalCounter","createdAt","groupIds","lastMessage","lastSenderId","user_\(EntourageManager.shared.user.id)"]

        
        docRef.setData(data, mergeFields: mergeFields) { (error) in
            completion(element,error)
        }
        
    }
    
    
    /// Converts rooms data to rooms
    ///
    /// - Parameter documentChanges: document changes
    /// - Returns: parsed MessageRoom
    fileprivate func parseObjectsMessage(from documentChanges:[DocumentChange]) -> [LastMessage]{
        let messages = LastMessageSDK.decodeElements(from: documentChanges) as [LastMessage]
        return messages
    }
    
    
    fileprivate func checkLastMessageReadStatus(doc: DocumentChange , completion:@escaping () -> Void){
        
        Matches = EntourageManager.shared.myMatchs
        myGroup = EntourageManager.shared.myGroup!
        
        let documentID = doc.document.documentID
        let message = doc.document.get("lastMessage") as? String ?? ""
        let messagesenderTime = doc.document.get("createdAt") as? Double ?? 0.0
        
        let senderId = doc.document.get("lastSenderId") as? Int ?? 0
        let chatTotalCounter = doc.document.get("chatTotalCounter") as? Int ?? 0
        let myChatCounter = doc.document.get("user_\(EntourageManager.shared.user.id)") as? Int ?? 0

        
        if senderId == getLastSender(key: documentID) , Date(timeIntervalSince1970: messagesenderTime) == getLastMsgTime(id: documentID){
        
            
        }else{
         
            
            saveLastMsgTime(time: Date(timeIntervalSince1970: messagesenderTime), id: documentID)

            //every Chat unread Msg Counter
            let chatUnreadCounter = chatTotalCounter - myChatCounter
            
            //save Every Chat unRead Msg Counter
            saveUnReadMsg(value: chatUnreadCounter , id: documentID)
            //save last Msg from Chat
            saveLastMsg(message: message, id: documentID)
            //save Last Sender Id
            saveLastSender(id: senderId , key: documentID)
            //save totalChat Counter
            totalCounter(value: chatTotalCounter, id: documentID)
            
            if documentID != "\(myGroup.id)" , Matches.contains(where:{ "Match_\($0.chat_id)" == documentID }){
                let allUnreadCounter = chatTotalCounter - myChatCounter
                
                incrementAllUnRead(value:allUnreadCounter)
                
                Utils.mainVC?.upadteMessageIcon()
                
                reOrderTheMatch(Matches: Matches)
                completion()
                
            }else{
                
                Utils.mainVC?.upadteMessageIcon()
                completion()
            }

        }
        
    }
    
}

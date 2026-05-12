//
//  ActiveMemberFireBaseService.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import Firebase


class ActiveMemberFireBaseService<ActiveMember:Codable>{
    
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
    
    static func creatActiveListner(id:String) -> ActiveMemberFireBaseService<ActiveMember>{
        let path = "Message/" + "\(id)" + "/ChatMembers"
        let collection = db.collection(path)
        let query = collection.order(by: "SenderId", descending: false)
        
        return ActiveMemberFireBaseService<ActiveMember>(collectionRef: collection, query: query)
    }

}


// MARK: - Methods
extension ActiveMemberFireBaseService{
    
    //GetAll Documents in One Collections
    public func fetchAllDocuments(personalChat:Bool,added:@escaping ([ActiveMember]) -> Void){
        
        self.firestoreCollectionRef.getDocuments { (querySnapshot, error) in
            //if no data
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            //added
            let addedChanges = snapshot.documentChanges.filter{ $0.type == .added }
            let addedObjects =  self.parseObjects(from: addedChanges)
            if addedObjects.count > 0 {added(addedObjects)}

        }
        

    }
    
    /// Gets one specific object in collection
    ///
    /// - Parameters:
    ///   - element: element
    ///   - completion: callback for completion
    public func fetch(docId:String, completion:@escaping (ActiveMember?,Error?) -> Void){
        
        let docRef = self.firestoreCollectionRef.document(docId)
        
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                
                
                //decode
                guard let element:ActiveMember = ActiveMemberSDK.decodeElement(from: document.data()!) else{
                    
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
    
    /// Returns auto document id for the new document
    public func autoDocumentId() -> DocumentReference {
        return self.firestoreCollectionRef.document()
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

    /// Updates one specific object in collection
    ///
    /// - Parameters:
    ///   - element: element
    ///   - completion: callback for completion
    public func addAcvtiveDoc(docId:String,element:ActiveMember, completion:@escaping (ActiveMember,Error?) -> Void){
        
        let data = ActiveMemberSDK.encodeElement(from: element)
        let docRef = self.firestoreCollectionRef.document(docId)
        docRef.setData(data) { error in
            completion(element,error)
        }
    }

    /// Converts rooms data to rooms
    ///
    /// - Parameter documentChanges: document changes
    /// - Returns: parsed MessageRoom
    fileprivate func parseObjects(from documentChanges:[DocumentChange]) -> [ActiveMember]{
        let elements = ActiveMemberSDK.decodeElements(from: documentChanges) as [ActiveMember]
        return elements
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

    /// stop listening to message form this room
    public func unsubscribe(){
        
        guard let registration = self.listener else{
            return
        }
        
        registration.remove()
    }

    
}

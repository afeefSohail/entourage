//
//  HelpingMethods.swift
//  entourage
//

import Foundation
import UIKit
import Contacts
import AlamofireImage

//MARK:- CallBacks
typealias getLocation = () -> Void
typealias PressOkay = ()->Void
typealias friendIds = ([Int]) -> Void
typealias createGroup = (Bool) -> Void
typealias importFriendsList = () -> Void
typealias matchStatusUpdate = (Bool) -> Void
typealias inviteGroup = (Bool) -> Void
typealias OtherUserProfile = (String) -> Void
typealias createCustomeStatus = (Bool,String) -> Void
typealias blockOrUnBlock = (Bool)->Void

//MARK: - ImageCrop Method
func setupThumnail(url: URL, IV: UIImageView) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data, let image = UIImage(data: data) else { return }
        DispatchQueue.main.async { IV.image = image.af.imageAspectScaled(toFill: IV.frame.size) }
    }.resume()
}

func setupAspectScaleThumnail(url: URL, IV: UIImageView) {
    URLSession.shared.dataTask(with: url) { data, _, _ in
        guard let data, let image = UIImage(data: data) else { return }
        DispatchQueue.main.async { IV.image = image.af.imageAspectScaled(toFit: IV.frame.size) }
    }.resume()
}

enum dateForamte : String{
    case year = "yyyy-dd-MM"
    case day = "dd-MM-yyyy"
    case month = "MMMM d, yyyy"
    case dateWithHour = "MM/dd/yyyy hh:mm a"
    case houreMin = "HH:mm"
    case onlyDay = "EEEE"
    case twelveHour = "hh:mm a"
    case meridiemSymbol = "a"
    case getMonth = "LLLL"
}

func openBrowserWith(url: String) {
    if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}

func dateToString(date: Date,formate:String)-> String {
    let dateFormatter: DateFormatter  = DateFormatter()
    dateFormatter.dateFormat = formate
    return dateFormatter.string(from: date)
}

func stringToDate(date: String,formate:String)-> Date {
    let dateFormatter: DateFormatter  = DateFormatter()
    dateFormatter.dateFormat =  formate
    let dateStr = dateFormatter.date(from: date)
    return dateStr!
}

func convertDateIntoSeconds(date: Date) -> Int {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    return (hour * 3600) + (minutes * 60) + seconds
}

func getNumberFromString(value: String) -> Int {
    if let number = Int(value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
        return number
    }
    return 0
}

func containsOnlyLetters(input: String) -> Bool {
    for chr in input.enumerated() {
        if (!(chr.element >= "a" && chr.element <= "z") && !(chr.element >= "A" && chr.element <= "Z") && !(chr.element >= "0" && chr.element <= "9")) {
            return false
        }
    }
    return true
}

//MARK: - Reorder The Match Messages Array
func reOrderTheMatch(Matches:[Match]){
    for (index1,match1) in Matches.enumerated(){
        let lastDate = getLastMsgTime(id: "Match_\(match1.chat_id)")
        for (index2,match2) in Matches.enumerated(){
            let nextDate = getLastMsgTime(id: "Match_\(match2.chat_id)")
            if index2 > index1, lastDate < nextDate {
                let temp = EntourageManager.shared.myMatchs[index1]
                EntourageManager.shared.myMatchs[index1] = EntourageManager.shared.myMatchs[index2]
                EntourageManager.shared.myMatchs[index2] = temp
            }
        }
    }
}

//MARK:- Delete The Group Document
import FirebaseAuth
import FirebaseFirestore

func deleteTheChatMessage(groupId:String,completetion:@escaping()->Void){
    let db = Firestore.firestore()
    db.collection("Message/").document(groupId).collection("/ChatMessages").getDocuments { (querySnapshot, error) in
        if error != nil { completetion() }
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            completetion()
            return
        }
        if snapshot.documents.count == 0 { completetion() }
        for (index,doc) in snapshot.documents.enumerated(){
            if index == snapshot.documents.count-1{
                doc.reference.delete()
                completetion()
            }else{
                doc.reference.delete()
            }
        }
    }
}

func deleteTheChatMember(groupId:String,completetion:@escaping()->Void){
    let db = Firestore.firestore()
    db.collection("Message/").document(groupId).collection("/ChatMembers").getDocuments { (querySnapshot, error) in
        if error != nil { completetion() }
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            completetion()
            return
        }
        if snapshot.documents.count == 0 { completetion() }
        for (index,doc) in snapshot.documents.enumerated(){
            if index == snapshot.documents.count-1{
                doc.reference.delete()
                completetion()
            }else{
                doc.reference.delete()
            }
        }
    }
}

func deleteTheDocument(groupId:String,completetion:@escaping()->Void){
    let db = Firestore.firestore()
    db.collection("Message/").document(groupId).delete { (error) in
        if error != nil{
            lastMessageListner?.unsubscribe()
            activeMemberListner?.unsubscribe()
            chatListener?.unsubscribe()
            completetion()
        }else{
            deleteTheChatMember(groupId: groupId) {
                deleteTheChatMessage(groupId: groupId) {
                    let totalMatch = EntourageManager.shared.myMatchs.count
                    if totalMatch == 0{
                        completetion()
                    }else{
                        deleteMatchTheDocument(db: db, index: 0, matchCount: totalMatch) {
                            completetion()
                        }
                    }
                }
            }
        }
    }
}

func deleteMatchTheDocument(db:Firestore,index:Int,matchCount:Int,callback:@escaping()->Void){
    if index >= matchCount{
        EntourageManager.shared.myMatchs = []
        lastMessageListner?.unsubscribe()
        activeMemberListner?.unsubscribe()
        chatListener?.unsubscribe()
        callback()
        return
    }
    db.collection("Message/").document("Match_\(EntourageManager.shared.myMatchs[index].chat_id)").delete { (error) in
        if error != nil{
            callback()
            return
        }else{
            deleteTheChatMember(groupId: "Match_\(EntourageManager.shared.myMatchs[index].chat_id)") {
                deleteTheChatMessage(groupId: "Match_\(EntourageManager.shared.myMatchs[index].chat_id)") {
                    deleteMatchTheDocument(db: db, index:index+1, matchCount: matchCount, callback: callback)
                }
            }
        }
    }
}

import Contacts
func contactsPermission(completetion:@escaping (_ granted:Bool,_ error: String) -> Void){
    let store = CNContactStore()
    store.requestAccess(for: .contacts) { (granted, error) in
        completetion(granted,error?.localizedDescription ?? "")
    }
}

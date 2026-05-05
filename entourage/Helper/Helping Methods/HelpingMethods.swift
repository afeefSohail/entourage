
//
//  HelpingMethods.swift
//  Hello.
//
//  Created by Furqan Ahmad on 02/05/2019.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import UIKit
import Contacts
import Kingfisher
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

//MARK:- Message Image
func getMsgCellView(view:UIView)->UIImage{
    let size = CGSize(width: view.bounds.size.width, height: view.bounds.size.height)
    let renderer = UIGraphicsImageRenderer(size: size)//made image of this view size
    let image = renderer.image { ctx in
//            do{
//                let copyView = try view.copyObject() as! UIView
            //copyView.backgroundColor = #colorLiteral(red: 0.9921568627, green: 0.5725490196, blue: 0.1137254902, alpha: 1)
            view.drawHierarchy(in:  view.bounds, afterScreenUpdates: true)//draw your view image on upper image rect

//            }catch{
//                print(error.localizedDescription)
//            }
    }
    
    return image//Utils.embedSignatureImage(mainImage: image, signatureImage: UIImage(named:"app_logo")!, position: nil)
}

//MARK: - ImageCrop Method
func setupThumnail(url:URL,IV:UIImageView){
    KingfisherManager.shared.retrieveImage(with: url, completionHandler: { (result) in
        if let image = try? result.get().image {
            IV.image = image.af_imageAspectScaled(toFill: IV.frame.size)
        }
    })

}

func setupAspectScaleThumnail(url:URL,IV:UIImageView){
    KingfisherManager.shared.retrieveImage(with: url, completionHandler: { (result) in
        if let image = try? result.get().image {
            IV.image = image.af_imageAspectScaled(toFit: IV.frame.size)
        }
    })

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

func setDateFormate(date: Date,formate:String)-> Date {
    let dts = dateToString(date: date, formate: formate)
    let std = stringToDate(date: dts, formate: formate)
    
    return std
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

func getWeekDayNameFromDate(date: String)-> Int? {
    
    let dateFormatter: DateFormatter  = DateFormatter()
    dateFormatter.dateFormat = "dd-MM-yyyy"
    guard let todayDate = dateFormatter.date(from: date) else{
        return nil
    }
    
    let myCalendar = Calendar(identifier: .gregorian)
    let weekDay = myCalendar.component(.day, from: todayDate)
    
    return weekDay
}



func convertDateIntoSeconds(date: Date) -> Int {
    
    let calendar = Calendar.current
    
    let hour = calendar.component(.hour, from: date)
    let minutes = calendar.component(.minute, from: date)
    let seconds = calendar.component(.second, from: date)
    
    let secondInHours = hour * 3600
    let secondInMin = minutes * 60
    
    return (secondInHours + secondInMin + seconds)
    
}

func roundDateDown(date: Date, toNearestMinuites: Int)-> Date {
    
    let calendar = Calendar.current
    let rightNow = Date()
    let nextDiff = toNearestMinuites - calendar.component(.minute, from: rightNow) % toNearestMinuites
    let roundedDate = calendar.date(byAdding: .minute, value: nextDiff, to: rightNow) ?? Date()
    
    return roundedDate
}



func getNumberFromString(value: String) -> Int {
    
    if let number = Int(value.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
        return number
    }
    
    return 0
}


func getNumberInFormate(intString:Int) -> String
{
    let formatter = NumberFormatter()              // Cache this, NumberFormatter creation is expensive.
    formatter.locale = Locale(identifier: "en_IN") // Here indian locale with english language is used
    formatter.numberStyle = .decimal               // Change to `.currency` if needed
    
    let asd = formatter.string(from: NSNumber(value: intString)) // "10,00,000"
    return asd ?? ""
}


func containsOnlyLetters(input: String) -> Bool {
    for chr in input.enumerated() {
        
        if (!(chr.element >= "a" && chr.element <= "z") && !(chr.element >= "A" && chr.element <= "Z") && !(chr.element >= "0" && chr.element <= "9")) {
            return false
        }
    }
    return true
}



func getImageViewWith(tag: Int, view: UIView) -> UIImageView {
    
    if let imageView = view.viewWithTag(tag) as? UIImageView {
        return imageView
    }
    
    // never gonna run
    return UIImageView()
}



func getViewWith(tag: Int, view: UIView) -> UIView {
    
    if let view = view.viewWithTag(tag) {
        return view
    }
    
    // never gonna run
    return UIView()
}

func getLabelWith(tag: Int, view: UIView) -> UILabel {
    
    if let label = view.viewWithTag(tag) as? UILabel {
        return label
    }
    
    // never gonna run
    return UILabel()
}


func getButtonWith(tag: Int, view: UIView) -> UIButton {
    
    if let button = view.viewWithTag(tag) as? UIButton {
        return button
    }
    
    // never gonna run
    return UIButton()
}

//MARK: - isEmoji
func isEmoji(_ value: Int) -> Bool {
    switch value {
    case 0x1F600...0x1F64F, // Emoticons
    0x1F300...0x1F5FF, // Misc Symbols and Pictographs
    0x1F680...0x1F6FF, // Transport and Map
    0x1F1E6...0x1F1FF, // Regional country flags
    0x2600...0x26FF,   // Misc symbols 9728 - 9983
    0x2700...0x27BF,   // Dingbats
    0xFE00...0xFE0F,   // Variation Selectors
    0x1F900...0x1F9FF,  // Supplemental Symbols and Pictographs 129280 - 129535
    0x1F018...0x1F270, // Various asian characters           127000...127600
    65024...65039, // Variation selector
    9100...9300, // Misc items
    8400...8447: // Combining Diacritical Marks for Symbols
        return true
       
    default: return false
    }
}
    
    func getValidEmoji(range:ClosedRange<Int>)->[String]{
        
        var unicdoeString : [String] = []
        
        for i in range where isEmoji(i) {
            if let scalar = UnicodeScalar(i) {
                let unicode = Character(scalar)
                if unicode.unicodeAvailable() {
                    unicdoeString.append(String(scalar))
                    //count += 1
                } else {
                    //notAvail += 1
                }
            } else {
                //notCounted += 1
            }
        }
        
        return unicdoeString
    }
//MARK: - Reorder The Match Messages Array
func reOrderTheMatch(Matches:[Match]){
    
    for (index1,match1) in Matches.enumerated(){
        
        let lastDate = getLastMsgTime(id: "Match_\(match1.chat_id)")
        
        for (index2,match2) in Matches.enumerated(){
            
            let nextDate =  getLastMsgTime(id: "Match_\(match2.chat_id)")
            
            if index2 > index1 ,  lastDate < nextDate{
                
                let temp = EntourageManager.shared.myMatchs[index1]
                EntourageManager.shared.myMatchs[index1] = EntourageManager.shared.myMatchs[index2]
                EntourageManager.shared.myMatchs[index2] = temp
            }
        }
        
    }
    
}

//MARK: - Message Active Notification Methdo
func MessageNotification(Id:Int){
    
    if Utils.chatRoom == true {
        
        if Utils.chatVC?.personalChat == true{
            
            if Utils.chatVC?.group.id != Id {
                
                Utils.transtion = true
                Utils.chatVC?.dismissNotificationChatRoom(dismissStatus: false, completeion: {
                    if let match = EntourageManager.shared.myMatchs.last(where: {$0.chat_id == Id}){
                        
                        Utils.currVC?.openChatVC(chatId: Id , group: match.matcher!, completeion: {
                            
                        })
                    }
                    
                })
            }
        
    }else if Utils.chatVC?.matchId != Id{
        
        Utils.chatVC?.dismissNotificationChatRoom(dismissStatus: false, completeion: {
            
            if let match = EntourageManager.shared.myMatchs.last(where: {$0.chat_id == Id}){
                Utils.currVC?.openChatVC(chatId: Id , group: match.matcher!, completeion: {
                    
                })
            }else if EntourageManager.shared.myGroup?.id ?? 0 == Id{
                Utils.currVC?.openChatVC(chatId: 0 , group: EntourageManager.shared.myGroup!, completeion: {
                    
                })
            }
            
        })//dismissChatRoom(dismissStatus: false)
        
        
    }
    
}else{
    
    if let match = EntourageManager.shared.myMatchs.last(where: {$0.chat_id == Id}){
        Utils.currVC?.openChatVC(chatId: Id , group: match.matcher!, completeion: {
            
        })
    }else if EntourageManager.shared.myGroup?.id ?? 0 == Id{
        
        Utils.currVC?.openChatVC(chatId: 0 , group: EntourageManager.shared.myGroup!, completeion: {
            
        })
    }
    
}
}

//MARK:- Delete The Group Document
import FirebaseAuth
import FirebaseFirestore

func deleteTheChatMessage(groupId:String,completetion:@escaping()->Void){
    
    let db = Firestore.firestore()
    
    db.collection("Message/").document(groupId).collection("/ChatMessages").getDocuments { (querySnapshot, error) in
        
        if error != nil{
            completetion()
        }

        //if no data
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            completetion()
            return
        }
        
        if snapshot.documents.count == 0 {
            
            completetion()
        }
        
        for (index,doc) in snapshot.documents.enumerated(){
            print("messge--> ",index)
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
        
        if error != nil{
            completetion()
        }
        //if no data
        guard let snapshot = querySnapshot else {
            print("Error fetching snapshots: \(error!)")
            completetion()
            return
        }
        
        if snapshot.documents.count == 0 {
            completetion()
        }

        for (index,doc) in snapshot.documents.enumerated(){
            print(index,"---",snapshot.documents.count)
            if index == snapshot.documents.count-1{
                print("member--> ",index)
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

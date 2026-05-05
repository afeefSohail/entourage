//
//  Contacts.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/28/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation
import UIKit
import Contacts

class PhoneContact {
    
    var name: String?
    var shortName : String?
    var nameIntials : String?
    var avatarData: Data?
    var phoneNumber: String = ""
    var email: [String] = [String]()
    var birthDay : String = ""
    var isSelected: Bool = false
    var isInvited = false
    
    init(contact: CNContact,phoneNumber:String) {
        name = contact.givenName + " " + contact.familyName
        avatarData  = contact.imageData
        shortName = contact.givenName
        
        if let firstname = contact.givenName.first{
            nameIntials = "\(String(firstname))"
        }else{
            nameIntials = ""
        }
        
        if let secondname = contact.familyName.first{
         nameIntials = "\(nameIntials ?? "")\(String(secondname))"
        }else{
            nameIntials = "\(nameIntials ?? "")"
        }
        
        if let dateOfBirth = contact.birthday?.date{
            birthDay = dateToString(date: dateOfBirth , formate: dateForamte.year.rawValue)
        }
        
        self.phoneNumber = phoneNumber
    
        for mail in contact.emailAddresses {
            email.append(mail.value as String)
        }
    }
    

}

class AllContacts {
    
    var phoneNumber : String = ""
    var nameIntials : String = ""
    var fullname : String = ""
    var userName : String = ""
    var avatarData: Data?
    var imageUrl : String = ""
    var isSelected = false
    var reloationStatus = "Request"
    
    init(name:String , num:String , nameIntials:String , userName:String,avatarData:Data?,imageUrl:String,reloationStatus:String) {
        self.nameIntials = nameIntials
        fullname = name
        self.userName = userName
        self.phoneNumber = num
        self.avatarData  = avatarData
        self.imageUrl = imageUrl
        self.reloationStatus = reloationStatus
    }
}

//
//  PhoneContacts.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/28/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Foundation
import Contacts

class PhoneContacts {
    
    class func getAllContacts() -> [PhoneContact] {
        
        var allContacts = [PhoneContact]()
        for contact in PhoneContacts.getContacts() {
            contact.phoneNumbers.forEach { (phoneNumber) in
                var newPhoneNumber = phoneNumber.value.stringValue.replacingOccurrences(of: " ", with: "")
                newPhoneNumber = newPhoneNumber.replacingOccurrences(of: "-", with: "")
                newPhoneNumber = newPhoneNumber.replacingOccurrences(of: "(", with: "")
                newPhoneNumber = newPhoneNumber.replacingOccurrences(of: ")", with: "")
                let newContact = PhoneContact(contact: contact, phoneNumber: newPhoneNumber)
                allContacts.append(newContact)
            }
        }
        
        return allContacts // here array has all contact numbers.
    }

   class func getContacts() -> [CNContact] { //  ContactsFilter is Enum find it below
        
        let contactStore = CNContactStore()
        let keysToFetch = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactPhoneNumbersKey,
            CNContactEmailAddressesKey,
            CNContactBirthdayKey,
            CNContactThumbnailImageDataKey,
            CNContactImageDataKey,
            CNContactNicknameKey,
            CNContactNamePrefixKey,
            CNContactNameSuffixKey] as [Any]
        
        var allContainers: [CNContainer] = []
        do {
            allContainers = try contactStore.containers(matching: nil)
        } catch let Er{
            print(Er.localizedDescription)
        }
        
        var results: [CNContact] = []
        
        for container in allContainers {
            let fetchPredicate = CNContact.predicateForContactsInContainer(withIdentifier: container.identifier)
            
            do {
                let containerResults = try contactStore.unifiedContacts(matching: fetchPredicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                results.append(contentsOf: containerResults)
            } catch let Er{
                print(Er.localizedDescription)
            }
        }
        return results
    }
    
    
}

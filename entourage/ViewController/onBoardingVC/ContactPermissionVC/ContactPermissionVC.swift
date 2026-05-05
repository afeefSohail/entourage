//
//  ContactPermissionVC.swift
//  entourage
//
//  Created by Furqan Ahmad on 5/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import Contacts


class ContactPermissionVC: BaseVC {
    
    //MARK: - IBOutLets
    @IBOutlet weak var labelone: UILabel!
    @IBOutlet weak var labelTwo: UILabel!
    @IBOutlet weak var settingsBtn: UIButton!
    
    //MARK:- Class Properties
    let store = CNContactStore()
    
    override func setupGUI() {
        super.setupGUI()
        
        self.setUpNavigationBar()
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Avenir-Medium", size: 18)!]
        
        //NavBar shadow
        self.addNavBarShadow()
        //NavBar Title
        self.title = "Contact Permission"
        
        self.labelTwo.isHidden = true
        self.settingsBtn.isHidden = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        contactsPermissionAlert()
    }
    
    func contactsPermissionAlert(){
        
        contactsPermission { (granted, error) in
            if granted {
                
                DispatchQueue.main.async {
                    
                    Utils.phoneContacts = PhoneContacts.getAllContacts()
                    UserDefaults.standard.set(false, forKey: "contactPermission")
                    UserDefaults.standard.set(true, forKey: "contacts")
                    
                    self.loadAddFriendsVC()
                    
                }
                
            } else {
                
                DispatchQueue.main.async {
                    self.labelone.text = "Contacts are turned off"
                    self.labelTwo.isHidden = false
                    self.settingsBtn.isHidden = false
                }
            }
            
        }
        
    }
    
    @IBAction func pressSettingsBtn(_ sender: Any) {
        UserDefaults.standard.set(true, forKey: "contactPermission")
        openBrowserWith(url: UIApplication.openSettingsURLString)
    }
    
    func requestAccess(completionHandler: @escaping (_ accessGranted: Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            
            completionHandler(true)
        case .denied:
            
            openBrowserWith(url: UIApplication.openSettingsURLString)
            completionHandler(false)
        case .restricted, .notDetermined:
            
            store.requestAccess(for: .contacts) { granted, error in
                if granted {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            }
        default:
            completionHandler(false)
        }
    }
    
}

//
//  FireBaseAuth.swift
//  entourage
//
//  Created by afeef sohail on 11/04/2020.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth

class FireBaseAuth {
    
    static var userPhoneNumber : String = ""
    static var verificationId : String = ""
    
    static func phoneVerificationWith(phoneNumber:String,complete:@escaping (_ success:String?,_ error:String?)->Void){
                
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                complete(nil,error.localizedDescription)
                return
            }
            
            userPhoneNumber = phoneNumber
            
            //persist the verification ID
            verificationId = verificationID ?? ""
            
            UserDefaults.standard.set(verificationID, forKey: "firebase_verification")
            UserDefaults.standard.synchronize()

            complete(verificationId,nil)
            
        }
    }
    
    static func getCredentialWith(verificationID : String , verificationCode:String)->PhoneAuthCredential{
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode)
        
        return credential
    }
    
    static func SignInWith(credential:PhoneAuthCredential,complete:@escaping (_ success:String?,_ error:String?)->Void){
        
        Auth.auth().signIn(with: credential) { (result, error) in
            
            if let error = error {
                complete(nil,error.localizedDescription)
                return
            }
            
            complete("Success",nil)
            
        }
    }
    
}

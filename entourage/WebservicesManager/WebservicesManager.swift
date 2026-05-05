//  WebservicesManager.swift
//  HappyTenantAPP
//
//  Created by afeef sohail on 11/27/18.
//  Copyright © 2018 VoidLabs. All rights reserved.
//

import Foundation

import UIKit
import CoreLocation
import Alamofire
//import FirebaseAuth
//import FirebaseFirestore

 /// standerd webserivces callback
 typealias WebServicesManagerCallback = (_ parse:Any? ,_ error: String?) -> Void
 
 /// Alamofirecallback
 fileprivate typealias AlamofireCallback = (DataResponse<Any>) -> Void
 
 class WebServicesManager: NSObject {
 
 /*shared instance*/
 static let shared = WebServicesManager()
 
    
 /*so no one else can initiat it*/
 fileprivate override init() {
 super.init()
//    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForRequest = 10
//    Alamofire.SessionManager.default.session.configuration.timeoutIntervalForResource = 10
    }
 
 /*internal*/
 fileprivate func url(relative:String) ->String{
 
 return Constants.baseURL + relative
 
 }
 
 func getProperError(errorData: Data) -> String{
 
 var errorString: String? = "Something went wrong"
 
    if let json = try? JSONSerialization.jsonObject(with: errorData as Data, options: []) as? [String: AnyObject] {
     
            errorString = json["error"] as? String
    }
 
 return errorString ?? "Something went wrong"
 
 }
 
     /*internal*/
     fileprivate func completionHandler (parsingHandler: @escaping AlamofireCallback , callback: @escaping WebServicesManagerCallback) -> AlamofireCallback {
     
     //alamofire callback
     let completionHandler: (DataResponse<Any>) -> Void = { (response) in
        switch response.result {
            
            case .success:
                //all parsing goes here
                parsingHandler(response)
         
            case .failure:

                callback(nil, self.getProperError(errorData: response.data!))
         }
    }
        
        return completionHandler
        
    }
    
 }
 

//MARK: onBoarding API
extension WebServicesManager{
    
    func checkUdpatetion(callback:@escaping WebServicesManagerCallback){
        
        guard let version = Bundle.main.infoDictionary?["CFBundleVersion"] as? String else {
            callback(nil,nil)
            return
        }

        let params = [
            "ios_version": version
            ] as [String:String]

        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.value{

                if let dic = responseData as? [String:Any]{
                    
                    if let status = dic["is_valid"] as? Bool{
                        callback(status,nil)
                    }else{
                        callback(false,nil)
                    }
                }
                
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/check_ios_version"),
                          method: .get,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)

    }
    
    //MARK: - User SignUp
    func UserSignUpBy(phoneNum: String , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "phone_number": phoneNum
            ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{

                do{
                    
                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                    
                    EntourageManager.shared.user = baseUser.user
                    EntourageManager.shared.photos = baseUser.user.photos
                    
                    EntourageManager.shared.user.saveToken()
                    
                    callback(baseUser.user,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/user_signup"),
                          method: .post,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)

    }

    //MARK: - Get User
    func getUser(callback : @escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken()
        ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{

                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)

                    
                    
                    EntourageManager.shared.user = baseUser.user
                    EntourageManager.shared.photos = baseUser.user.photos
                    EntourageManager.shared.groupInviteRequestes = baseUser.user.pendingGroupInvitation ?? []

                    EntourageManager.shared.user.saveToken()

                    callback(baseUser.user,nil)

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/user_by_auth_token"),
                          method: .get,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        
    }
    
    func getUserBy(phoneNum:String , callback : @escaping WebServicesManagerCallback){
        
        let params = [
            "phone_number":  phoneNum
            ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                    
                    
                    
                    EntourageManager.shared.user = baseUser.user
                    EntourageManager.shared.photos = baseUser.user.photos
                    
                    EntourageManager.shared.groupInviteRequestes = baseUser.user.pendingGroupInvitation ?? []

                    EntourageManager.shared.user.saveToken()

                    callback(baseUser.user,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/user_by_phone_number"),
                          method: .get,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        
    }


    //MARK: - Eidt User Profile
    func editUserProfile(checkAge:Bool,callback:@escaping WebServicesManagerCallback){
        
        let user = EntourageManager.shared.user
        
        var params = [
            "auth_token":  User.getToken(),
            "gender" : user.gender ?? "male",
            "first_name" : user.first_name ?? "" ,
            "user_name" : user.user_name ?? "" ,
            "last_name" : user.last_name ?? "",
            "dob" : user.dob ?? ""  ,
            "bio" : user.bio ?? ""
        ] as [String:Any]
        
        if checkAge == false{
            params.removeValue(forKey: "dob")
        }
        

        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                    
                    EntourageManager.shared.user = baseUser.user
                    
                    EntourageManager.shared.photos = baseUser.user.photos

                    callback(baseUser.user,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/edit_profile"),
                          method: .post,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)

        
    }
    
    //MARK: - User Name Availablity
    func checkUserNameAvailablityBy(userName:String,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "user_name": userName.lowercased()
            ] as [String:String]

        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let reponseData = response.value{
                
                let responseMessage = reponseData as! [String:Any]
                
                    if let _  = responseMessage["message"] as? String{
                        
                        callback("Yes",nil)
                    
                    }
                
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/user_name_available"),
                          method: .get,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        

        
    }
    
    //MARK: - deleteUserAccount
    func deleteUserAccount(reason:String,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "reason" : reason
            ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{

                
                callback(nil,nil)
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/delete_account"),
                          method: .delete,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)

    }
    
    //MARK: - Update User Location coordinates
    func updateLocationBy(callback:@escaping WebServicesManagerCallback){
       let user = EntourageManager.shared.user
        let params = [
            "auth_token": User.getToken(),
            "latitude" :   user.latitude ?? "", //String(coordinate.latitude),
            "longitude" : user.longitude ?? "" //String(coordinate.longitude)
            ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                do{
                    
                    
                    
                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                    
                    EntourageManager.shared.user = baseUser.user
                    EntourageManager.shared.photos = baseUser.user.photos

                    callback(baseUser.user, nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/update_coordinates"),
                          method: .post,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)

    }
    
    //MARK: - User by PhoneNumber
    func searchBy(userName:String,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token" : User.getToken(),
            "user_name": userName
            ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do {
                    
                    var friendsLsitBase = try JSONDecoder().decode(BaseFriendShip.self , from: responseData)
                    
                    let users = friendsLsitBase.users
                    
                    if users?.count ?? 0 > 0 {
                        
                        for (_,user) in users!.enumerated(){
                            let object = Friend.friendUser(user: user, status: "no_relation")
                            friendsLsitBase.friendships.append(object)
                        }
                        
                        //remove your Self from the list
                        if let index = friendsLsitBase.friendships.lastIndex(where: {$0.phone_number ?? "" == EntourageManager.shared.user.phone_number ?? ""}){
                            friendsLsitBase.friendships.remove(at: index)
                        }

                        callback(friendsLsitBase.friendships,nil)
                        
                    }else{
                        
                        //remove your Self from the list
                        if let index = friendsLsitBase.friendships.lastIndex(where: {$0.phone_number ?? "" == EntourageManager.shared.user.phone_number ?? ""}){
                            friendsLsitBase.friendships.remove(at: index)
                        }

                        callback(friendsLsitBase.friendships,nil)
                    }

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/search_by_user_name"),
                          method: .get,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        
        
        
    }
    
    func reportUser(user:User,reason:String,image:UIImage,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "user_id" : user.id,
            "reason" : reason
        ] as [String:Any]
        
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let data = image.imageData{
                    multipartFormData.append(data, withName: "image", fileName: "Report_\(user.name()).png", mimeType: "image/png")
                }
                
                for (key, value) in params {
                    if value is String {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key as String)
                    } else if value is Bool {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }else if  value is Int {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
            
        },
            to: url(relative: "/api/v1/users/report"),
            method: .post,
            encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let _ = response.data{
                          
                            callback(nil, nil)
                        }
                    }
                    
                case .failure(let error):
                    callback(nil, error as? String)
                }
        })
        
    }

    func sendInviteMessage(phoneNumber:String , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "phone_number" : phoneNumber
            ] as [String:String]

        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.value{
                callback("MessageSend",nil)
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/send_message_invite"),
                          method: .post,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        
    }
    
    
}

//MARK: - Photos
extension WebServicesManager{
    
    func uploadPhoto(image:Data , isPrimary:Bool,order:Int,callback:@escaping WebServicesManagerCallback){
        
        var params = [
            "auth_token": User.getToken(),
            "order" : order
        ] as [String:Any]
        
        
        if isPrimary == true{
            params ["is_primary"] = isPrimary
        }

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                let index = EntourageManager.shared.photos.count
                multipartFormData.append(image, withName: "image", fileName: "File\(index).png", mimeType: "image/png")
                
                for (key, value) in params {
                    if value is String {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key as String)
                    } else if value is Bool {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }else if  value is Int {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
            
        },
            to: url(relative: "/api/v1/photos/upload_photo"),
            method: .post,
            encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let responseData = response.data{
                            do{
                                
                                
                                
                                let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                                
                                EntourageManager.shared.user.photos = baseUser.user.photos
                                EntourageManager.shared.photos = baseUser.user.photos

                                callback(baseUser.user, nil)
                                
                                
                            }catch let Err{
                                callback(nil, nil)
                                print("Error serializing json = >\n",Err)
                            }
                        }
                    }
                    
                case .failure(let error):
                    callback(nil, error as? String)
                }
        })

    }

    //delete the Photo
    func deletePhotot(photoId:Int , callback : @escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token" : User.getToken(),
            "id" : photoId
        ] as [String:Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                    
                    EntourageManager.shared.user = baseUser.user
                    EntourageManager.shared.photos = baseUser.user.photos

                    callback(nil,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/photos/delete_photo"),
                          method: .delete,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        
    }
    
    //delete the Photo
    func setOrderPhotot(photoId:Int , order:Int , isPrimary:Bool , callback : @escaping WebServicesManagerCallback){
        
        var params = [
            "auth_token" : User.getToken(),
            "id" : photoId,
            "order" : order
            ] as [String:Any]
        
        if isPrimary == true{
            params ["is_primary"] = isPrimary
        }
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    
                    let baseUser = try JSONDecoder().decode(BaseUser.self , from: responseData)
                    
                    EntourageManager.shared.user = baseUser.user
                    EntourageManager.shared.photos = baseUser.user.photos

                    callback(nil,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/photos/set_order"),
                          method: .post,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)
        
    }

    
}


// MARK: - Setting
extension WebServicesManager{
    
    func getUserSettings(callback : @escaping WebServicesManagerCallback){
        
                let params = [
                    "auth_token" : User.getToken(),
                ] as [String:Any]
                
                let parsingHandler:AlamofireCallback = { (response ) in
                    
                    if let responseData = response.data{
                        
                        do{
                            
                            let userSetting = try JSONDecoder().decode(Settings.self , from: responseData)
                            
                            EntourageManager.shared.setting = userSetting.setting

                            callback(userSetting.setting,nil)
                            
                        }catch let Err{
                            print("Error serializing json = >\n",Err)
                        }
                    }
                    
                }
                
                //completion handlder for the alamofire
                let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
                
                //send to server
                Alamofire.request(url(relative: "/api/v1/users/my_setting"),
                                  method: .get,
                                  parameters:params).validate().responseJSON(completionHandler: completionHandler)

        
    }
    
    func updateSettings(callback : @escaping WebServicesManagerCallback){
        
        let setting = EntourageManager.shared.setting
        
        let params = [
            "auth_token":  User.getToken(),
            "everyone" : setting?.everyone ?? false,
            "male_only" :  setting?.male_only ?? false ,
            "female_only" : setting?.female_only ?? false  ,
            "min_age" : setting?.min_age ?? 18,
            "max_age" : setting?.max_age ?? 42 ,
            //"group_member_count" : setting?.group_member_count ?? 3,
            "max_distace" : setting?.max_distace ?? 50,
            "general" : setting?.general ?? false ,
            "friendship" : setting?.friendship ?? false,
            "match" : setting?.match ?? false ,
            "group" : setting?.group ?? false,
            "chat" : setting?.chat ?? false
            ] as [String:Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let userSetting = try JSONDecoder().decode(Settings.self , from: responseData)
                    
                    EntourageManager.shared.setting = userSetting.setting

                    callback(EntourageManager.shared.setting,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/users/edit_setting"),
                          method: .post,
                          parameters:params).validate().responseJSON(completionHandler: completionHandler)

    }
    
}

// MARK: - Notification
extension WebServicesManager{
    //sendNotification
    func sendNotification(message:String,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "user_id" : EntourageManager.shared.user.id,
            "message" : message
            //"type": "",
            ] as [String : Any]

        let parsingHandler:AlamofireCallback = { (response ) in
            
            callback(nil, nil)
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/notifications/send_notification"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    
    }
}


// MARK: - Groups
extension WebServicesManager{
    
    func createGroup(groupStatusId: Int, friendsIds:String, callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token": User.getToken(),
            "friend_ids" : friendsIds,
            "group_status_id" : groupStatusId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                
                do{
                    
                    let groupBase = try JSONDecoder().decode(MyGroup.self , from: responseData)
                    
                    EntourageManager.shared.myGroup = groupBase.group
                                        
                    RecentUsers.saveRecentUsers(Users: groupBase.group?.users ?? [])

                    callback(groupBase.group, nil)

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/create"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }
    
    func addMember(groupId : Int, friendsId:Int , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "group_id" : groupId,
            "friend_id" : friendsId
            ] as [String:Any]

        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                
                do{
                    
                    let groupBase = try JSONDecoder().decode(MyGroup.self , from: responseData)
                    
                    EntourageManager.shared.myGroup = groupBase.group
                                        
                    RecentUsers.saveRecentUsers(Users: groupBase.group?.users ?? [])
                    callback(groupBase.group,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/add_member"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

        
    }
    
    func myGroup(callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token": User.getToken(),
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data {
                
                                
                    do{
    
                        let groupBase = try JSONDecoder().decode(MyGroup.self , from: responseData)

                        
                        if groupBase.group != nil {
                            
                            EntourageManager.shared.myGroup = groupBase.group
                            
//                            let todayDate = Date().localDate()
 //                           EntourageManager.shared.myGroup?.spotLightRemainingTime = 86400 - todayDate.getSecondsToday() 
                            callback(EntourageManager.shared.myGroup,nil)
                            
                        }else{
                            
                            callback(nil,nil)
                        }
                        
                    }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
        }
    }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/my_group"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }

    func updateGroupStatus(groupId:Int,groupStatusId:Int, callback :@escaping  WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "group_id":groupId,
            "group_status_id" : groupStatusId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                
                do{
                    
                    let groupBase = try JSONDecoder().decode(MyGroup.self , from: responseData)
                    
                    EntourageManager.shared.myGroup = groupBase.group
                    
                    callback(groupBase.group,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/update_group_status"),
                          method: .put,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }
    
    
    func leaveGroup(callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token": User.getToken(),
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{
                
                callback(nil,nil)
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/leave_group"),
                          method: .delete,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }
    
    func deleteInivitation(groupId:Int, friendId: Int, callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token" : User.getToken(),
            "group_id" : groupId,
            "friend_id"  : friendId
            
        ] as [String:Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{
                
                if let index = EntourageManager.shared.myGroup?.invitedUsers?.firstIndex(where: {$0.id == friendId}){
                    EntourageManager.shared.myGroup?.invitedUsers?.remove(at: index)
                }
                
                
                callback(nil,nil)
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/delete_invitation"),
                          method: .delete,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }
    
    
    func acceptGroupInvite(groupId:Int,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token" : User.getToken(),
            "group_id" : groupId
        ] as [String:Any]

        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    let groupBase = try JSONDecoder().decode(MyGroup.self , from: responseData)
                    
                    if let index = EntourageManager.shared.groupInviteRequestes.lastIndex(where: {$0.id == groupBase.group?.id ?? 0}) {
                        EntourageManager.shared.groupInviteRequestes.remove(at: index)
                    }
                    
                    EntourageManager.shared.myGroup = groupBase.group
                    
                    
                    
                    
                    callback(groupBase.group,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }

                
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/accept_group_invitation"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }

    func rejectGroupInvite(groupId:Int,callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token" : User.getToken(),
            "group_id" : groupId
        ] as [String:Any]

        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{
                
                if let index = EntourageManager.shared.groupInviteRequestes.lastIndex(where: {$0.id == groupId}) {
                    EntourageManager.shared.groupInviteRequestes.remove(at: index)
                }

                callback(nil,nil)
            }
            
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/reject_group_invitation"),
                          method: .delete,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }

    func getGroupBy(groupId:Int,callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token" : User.getToken(),
            "group_id" : groupId
        ] as [String:Any]

        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    let groupBase = try JSONDecoder().decode(MyGroup.self , from: responseData)
                    
                    
                    callback(groupBase.group,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }

                
            }

        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/group_by_id"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }

    func spotlight(callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken()
        ] as [String:String]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{

                EntourageManager.shared.user.spotLightAllow! = 0
                
                callback(nil,nil)
            }
        }
    
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/groups/enable_spot_light"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }
        

}


// MARK: - Matches
extension WebServicesManager{
    
    func findGroupsToMatch(page:Int,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "page" : page
        ] as [String : Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let otherGroups = try JSONDecoder().decode(OtherGroups.self , from: responseData)
                    
                    otherGroups.groups.forEach { (group) in
                        if group.users.count == 0 || group.status != "active" {
                            if let index = otherGroups.groups.lastIndex(where: {$0.id == group.id}){
                                otherGroups.groups.remove(at: index)
                            }
                        }
                    }
                    
                    callback(otherGroups,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }

            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/find_groups"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }
    
    func likeTheGroup(groupId:String,callback:@escaping WebServicesManagerCallback){
       
        let params = [
            "auth_token": User.getToken(),
            "group_id"  : groupId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let likeGroup = try JSONDecoder().decode(MyMatche.self , from: responseData)
                    
                
                    callback(likeGroup.match,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/like_group"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

        
    }

    func unLikeTheGroup(groupId:String,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "group_id"  : groupId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let likeGroup = try JSONDecoder().decode(MyMatche.self , from: responseData)
                    
                    
                    callback(likeGroup.match,nil)

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/unlike_group"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
        
    }

    func matchList(callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken()
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let myMatches = try JSONDecoder().decode(MyMatches.self , from: responseData)
                    
                    EntourageManager.shared.myMatchs.removeAll()
                    EntourageManager.shared.myMatchs = myMatches.matches
                    reOrderTheMatch(Matches: EntourageManager.shared.myMatchs)

                    callback(EntourageManager.shared.myMatchs,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/my_matches"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    func unMatchTheGroup(groupId:String , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "group_id" :groupId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            callback(nil, nil)
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/unmatch_group"),
                          method: .delete,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    func instantMatch(groupId:String , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "group_id" :groupId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            if let responseData = response.data{
                
                do{
                    
                    let likeGroup = try JSONDecoder().decode(MyMatche.self , from: responseData)
                    
                    
                    
                    callback(likeGroup.match,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }

        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/instant_match"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    func resetOtherGroupStatus(groupId:String , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "group_id" :groupId
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            if let _ = response.data{
                
                callback(nil, nil)
            }

        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/matches/revert"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    
    
    
    
    
}




// MARK: - friendships
extension WebServicesManager{
    
    
    func directFriendShip(phoneNumber:String,callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token": User.getToken(),
            "phone_number" : phoneNumber
            ] as [String : String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let friend = try JSONDecoder().decode(FriendShip.self , from: responseData)
                    callback(friend.friendship_user, nil)

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }

        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/direct_friendship"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    func getFriendsList(callback:@escaping WebServicesManagerCallback){
    
        let params = [
            "auth_token": User.getToken()
        ] as [String:String]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let friendsLsitBase = try JSONDecoder().decode(BaseFriendShip.self , from: responseData)

                    EntourageManager.shared.FriendShips = friendsLsitBase.friendships
                    
                    callback(friendsLsitBase.friendships,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/friendes"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

        
    }

    func getFriendsListBy(contacts : String,directFriendship:Bool ,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "phone_numbers" : contacts,
            "direct_friendship": directFriendship
            ] as [String:Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                
                    var friendsLsitBase = try JSONDecoder().decode(BaseFriendShip.self , from: responseData)
                    
                    let users = friendsLsitBase.users
                    
                    if users?.count ?? 0 > 0 {
                        
                        for (_,user) in users!.enumerated(){
                            let object =  Friend.friendUser(user: user, status:"Request")
                            friendsLsitBase.friendships.append(object)
                        }
                        
                        callback(friendsLsitBase.friendships,nil)
                        
                    }else{
                        callback(friendsLsitBase.friendships,nil)
                    }
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/all_friends_and_requests"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
        
    }
    
    func getReceviedRequests(callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken()
            ] as [String:String]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                
                    var requestFriends = try JSONDecoder().decode(RequestFriends.self , from: responseData)
                    
//                    //remove your Self from the list
//                    if let index = requestFriends.friendships.lastIndex(where: {$0.phone_number ?? "" == EntourageManager.shared.user.phone_number ?? ""}){
//                        requestFriends.friendships.remove(at: index)
//                    }

                    callback(requestFriends.friendships,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/received_requests"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
        
    }

    func getAppContacts(callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken()
            ] as [String:String]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                
                    var appContacts = try JSONDecoder().decode(RequestFriends.self , from: responseData)

                    //remove your Self from the list
                    if let index = appContacts.friendships.lastIndex(where: {$0.phone_number ?? "" == EntourageManager.shared.user.phone_number ?? ""}){
                        appContacts.friendships.remove(at: index)
                    }

                    callback(appContacts.friendships,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/no_relation"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
        
    }

    func getFriendsAndInvited(contacts : String ,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "phone_numbers" : contacts
            ] as [String:String]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                
                    var allFriendsWithInviteNumber = try JSONDecoder().decode(FriendsWithInvitedUser.self , from: responseData)

                    //remove your Self from the list
                    if let index = allFriendsWithInviteNumber.friendships.lastIndex(where: {$0.phone_number ?? "" == EntourageManager.shared.user.phone_number ?? ""}){
                        allFriendsWithInviteNumber.friendships.remove(at: index)
                    }
                    
                    callback(allFriendsWithInviteNumber,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/friends_and_no_relation"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
        
    }

    
    func sendRequest(frendId:Int , callback:@escaping WebServicesManagerCallback){
     
        let params = [
            "auth_token": User.getToken(),
            "friend_id" : frendId
            ] as [String : Any]
        
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let Friendship = try JSONDecoder().decode(FriendShip.self , from: responseData)
                    
                    
                    callback(Friendship.friendship_user ,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/request"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }

    func acceptRequest(frendId:Int , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "friend_id" : frendId
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{

                    let Friendship = try JSONDecoder().decode(FriendShip.self , from: responseData)
                    
                    callback(Friendship.friendship_user ,nil)

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/accept"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }

    
    func blockFriend(frendId:Int, reason:String? = nil , abusiveMsg:UIImage? = nil , callback:@escaping WebServicesManagerCallback){
        
        var params = [
            "auth_token": User.getToken(),
            "friend_id" : frendId,
        ] as [String:Any]
        
        if reason != nil{
            params["reason"] = "Abusive content."
        }
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                if let data = abusiveMsg?.imageData{
                    multipartFormData.append(data, withName: "image", fileName: "Block_\(frendId)).png", mimeType: "image/png")
                }
                
                for (key, value) in params {
                    if value is String {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key as String)
                    } else if value is Bool {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }else if  value is Int {
                        multipartFormData.append("\(value)".data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
            
        },
            to: url(relative: "/api/v1/friendships/block"),
            method: .post,
            encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let responseData = response.data{
                            
                            do{
                                let Friendship = try JSONDecoder().decode(FriendShip.self , from: responseData)
                                
                                callback(Friendship.friendship_user ,nil)

                            }catch let Err{
                                print("Error serializing json = >\n",Err)
                            }
                        }
                    }
                    
                case .failure(let error):
                    callback(nil, error as? String)
                }
        })
        
    }

    func unFriend(frendId:Int , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "friend_id" : frendId
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{
                
                callback(nil ,nil)

//                do{
//                    let Friendship = try JSONDecoder().decode(FriendShip.self , from: responseData)
//
//
//                }catch let Err{
//                    print("Error serializing json = >\n",Err)
//                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/unfriend"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }

    
    func getBlockedFriends(callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken()
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{

                do{
                    let Friendship = try JSONDecoder().decode(BaseFriendShip.self , from: responseData)

                    callback(Friendship.friendships ,nil)

                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/blocked"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }
    
    func unblockedTheUsers(block_users:String , callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "blocked_user_ids" : block_users
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let _ = response.data{

                callback(nil,nil)
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/unblock"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }

    func checkUserFriendStatus(frendId:Int , callback:@escaping WebServicesManagerCallback){
        let params = [
            "auth_token": User.getToken(),
            "friend_id" : frendId
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.value{

                guard let dict = responseData as? [String:Any] else{
                    callback(nil,nil)
                    return
                }
                
                if let status = dict["status"] as? String{
                    callback(status,nil)
                }else{
                    callback(nil,nil)
                }
                
                
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/friendships/status"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)

    }
    
}

//MARK: - GroupStatus
extension WebServicesManager{
    
    func getGroupStatus(lisType:String,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "status_type" : lisType
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let groupStatusBase = try JSONDecoder().decode(GroupStatusBase.self , from: responseData)
                    
                    EntourageManager.shared.groupStatuses = groupStatusBase.group_statuses
                    
                    callback(groupStatusBase.group_statuses,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/group_statuses/all"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    func getRecentCoustomeGroupStatus(callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if let responseData = response.data{
                
                do{
                    
                    let groupStatusBase = try JSONDecoder().decode(GroupStatusBase.self , from: responseData)
                    
                    
                    callback(groupStatusBase.group_statuses,nil)
                    
                }catch let Err{
                    print("Error serializing json = >\n",Err)
                }
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/group_statuses/recent"),
                          method: .get,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }

    func createCustomStatus(statusName:String ,image:Data,callback:@escaping WebServicesManagerCallback){
        
        let params = [
            "auth_token": User.getToken(),
            "name" : statusName
        ] as [String:Any]
        
        

        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(image, withName: "icon", fileName: "Emojy\(statusName).png", mimeType: "image/png")
                
                for (key, value) in params {
                    if value is String {
                        multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key as String)
                    }
                }
            
        },
            to: url(relative: "/api/v1/group_statuses/create"),
            method: .post,
            encodingCompletion: { result in
                switch result {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        if let responseData = response.data{
                            
                            do{
                                
                                let currGroupStatus = try JSONDecoder().decode(GroupStatus.self , from: responseData)

                                callback(currGroupStatus.group_status!, nil)
                                
                                
                            }catch let Err{
                                print("Error serializing json = >\n",Err)
                            }
                        }
                    }
                    
                case .failure(let error):
                    callback(nil, error as? String)
                }
        })

        
    }
}

// MARK: - Device
extension WebServicesManager{
    
    //update fcm to server
    //register for push
    func registerForNotificationsWith(fcmToken:String,callback:@escaping WebServicesManagerCallback){
        
        
        let params = [
            "auth_token": User.getToken(),
            "physical_address" : UIDevice.current.identifierForVendor?.uuidString ?? "",
            "fcm_token" : fcmToken,
            "device_type": "iphone",
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            
            callback(nil, nil)
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request(url(relative: "/api/v1/devices/update_device_token"),
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
        
    }
    
    
    func sendLastMessageNotification(lastMsg:String , matchId:Int,fcmToken:[String] , msgGroup:Int , callback:@escaping WebServicesManagerCallback){
        
        
        let notification = [
            "title" : "Entouarge",
            "sound" : "message.wav",
            "body" : "💬 \(EntourageManager.shared.user.first_name ?? "") sent you a Message"
        ]
                
        let data = [
            "notifiable_type" : "Message",
            "notifiable_id" : "\(matchId)",
            "group_id" : "\(msgGroup)",
            "message" : "💬 \(EntourageManager.shared.user.first_name ?? "") sent you a Message",
            "group_fcm_tokens" : fcmToken,
            "notification" : notification
            ] as [String : Any]
        
        let params = [
            "data" : data
            ] as [String : Any]
        
        let parsingHandler:AlamofireCallback = { (response ) in
            
            if response.data != nil{
                callback("Success",nil)
            }
        }
        
        //completion handlder for the alamofire
        let completionHandler = self.completionHandler(parsingHandler: parsingHandler, callback: callback)
        
        //send to server
        Alamofire.request("https://us-east1-entourage-12345.cloudfunctions.net/sendNotificationToUsers",
                          method: .post,
                          parameters: params).validate().responseJSON(completionHandler: completionHandler)
    }
    

    
}

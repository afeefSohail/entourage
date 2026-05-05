//
//  EntourageManager.swift
//  entourage
//
//  Created by afeef sohail on 7/27/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import Foundation

class EntourageManager {
    
    //currentUser
    var user : User = User()
    
    //UserSettings
    var setting : Setting?
    
    //User photos
    var photos : [Photo] = []
    
    //MyFriends
    var FriendShips : [Friend] = []
    
    //group
    var myGroup : Group?
    
    //Group Status list
    var groupStatuses : [GroupStatuses] = []
    
    //All OtherGroups
    var otherGroups : [Group] = []
    
    //MyMatches
    var myMatchs : [Match] = []
    
    var groupInviteRequestes : [Group] = []
    
    /// shared instance
    fileprivate static let _sharedManager = EntourageManager()
    
    class var shared : EntourageManager {
        return _sharedManager
    }

    func getFriensOnly(allGroupMembers:[User]) -> [User]{
        
        var onlyFriends : [User] = []
        let groupIds = allGroupMembers.compactMap({$0.id})
        
        self.FriendShips.forEach { (friend) in
            if groupIds.contains(where: {$0 == friend.id}){
                print("Nothing to do")
            }else{
                onlyFriends.append(User.userFriend(user: friend))
            }
        }
        
        return onlyFriends
    }
    
    func reSetAppData(){
        let likeSwipeActionDemo  = UserDefaults.standard.bool(forKey: firstLikeSwipe)
        let unLikeSwipeActionDemo  = UserDefaults.standard.bool(forKey: firstUnLikeSwipe)
        let spotLightUse = UserDefaults.standard.bool(forKey: spotLiteUserDefaultKey)
        let iMatchUse  = UserDefaults.standard.bool(forKey: iMatchUserDefaultKey)

        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()

        UserDefaults.standard.set(unLikeSwipeActionDemo, forKey: firstUnLikeSwipe)
        UserDefaults.standard.set(likeSwipeActionDemo, forKey: firstLikeSwipe)
        UserDefaults.standard.set(spotLightUse, forKey: spotLiteUserDefaultKey)
        UserDefaults.standard.set(iMatchUse, forKey: iMatchUserDefaultKey)
    }
}

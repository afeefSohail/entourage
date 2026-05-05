//
//  RecentUsers.swift
//  entourage
//
//  Created by afeef sohail on 1/4/20.
//  Copyright © 2020 West Bay Technologies. All rights reserved.
//

import UIKit

class RecentUsers {
    
    public static func saveRecentUsers(Users:[User]){
        
        var recentUser = getSavedRecentUsers() ?? []
        
        // excpet me all users in this list
        var newUser : [User] = []

        Users.forEach { (user) in
            if let _ = EntourageManager.shared.FriendShips.last(where: {$0.id == user.id}){
                newUser.append(user)
            }
        }
        
        let checkedUser = checkSameUser(saveUser: recentUser, newUser: &newUser)
        
        let users = checkedUser.filter({$0.id != EntourageManager.shared.user.id})

        if (recentUser.count + users.count) <= 5{
            
            recentUser.insert(contentsOf: users, at: 0)//add new User in Array at the top

            let placesData = try! JSONEncoder().encode(recentUser)
            UserDefaults.standard.set(placesData, forKey: "recentUers")
            UserDefaults.standard.synchronize()
        }else{
            let totalUserCount = (recentUser.count + users.count) // count of Old RecentUser Save
            
            for _ in 1...totalUserCount{//remove last those RecentUser becuase totalUserCount is more than 5
                recentUser.removeLast()
            }
            
            recentUser.insert(contentsOf: users, at: 0)//add new User in Array at the top
            
            let placesData = try! JSONEncoder().encode(recentUser)
            UserDefaults.standard.set(placesData, forKey: "recentUers")
            UserDefaults.standard.synchronize()

        }
        
    }
    
    public static func checkSameUser(saveUser:[User], newUser: inout [User])->[User]{
        
        
        saveUser.forEach { (user) in
            if let index = newUser.lastIndex(where: {$0.id == user.id}){
                newUser.remove(at: index)
            }
        }
        
        return newUser
    }
    
    public static func getSavedRecentUsers() -> [User]?{
        guard let recentUsersData = UserDefaults.standard.data(forKey: "recentUers") else{
            return nil
        }
        let userArray = try! JSONDecoder().decode([User].self, from: recentUsersData)
        
        return userArray
    }

    public static func removeRecentUser(userIndex: Int) {
        var users = getSavedRecentUsers()!
        users.remove(at: userIndex)
        saveRecentUsers(Users:users)
    }

}

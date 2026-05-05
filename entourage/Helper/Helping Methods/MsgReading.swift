//
//  MsgReading.swift
//  entourage
//
//  Created by afeef sohail on 10/5/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit

func saveLastMsgTime(time:Date,id:String){
    UserDefaults.standard.set(time, forKey: "CreateAt\(id)")
}

func getLastMsgTime(id:String)->Date{
    if let date = UserDefaults.standard.object(forKey: "CreateAt\(id)") as? Date {
        return date
    }
    return Date("2015-04-01T00:00:00")!
}

func removeLastMsgTime(id:String){
    UserDefaults.standard.removeObject(forKey: "CreateAt\(id)")
}



// MARK: - LastMsg
func saveLastMsg(message:String,id:String){
    UserDefaults.standard.set(message, forKey: "\(id)")
}

func getLastMsg(id:String)->String{
    let groupLastMsg = UserDefaults.standard.object(forKey:"\(id)" ) as? String ?? ""
    
    return groupLastMsg
}

func removeLastMsg(id:String){
    UserDefaults.standard.removeObject(forKey: "\(id)")
}


// MARK: - LastSender
func saveLastSender(id:Int,key:String){
    UserDefaults.standard.set(id, forKey: "Sender\(key)")
    
}

func getLastSender(key:String)->Int{
    let counter = UserDefaults.standard.integer(forKey: "Sender\(key)" )
    
    return counter
}

func removeLastSender(key:String){
    UserDefaults.standard.removeObject(forKey: "Sender\(key)")
}


// MARK: - MyMsg
func saveMyMsg(message:String,id:String){
    UserDefaults.standard.set(message, forKey: "\(id)")
}

func getMyMsg(id:String)->String{
    let myMsg = UserDefaults.standard.object(forKey:"\(id)" ) as? String ?? ""
    
    return myMsg
}

func removeMyMsg(id:String){
    UserDefaults.standard.removeObject(forKey: "\(id)")
}

// MARK: - MyMsgReadCounter
func totalCounter(value:Int , id:String){
    UserDefaults.standard.set(value, forKey: "total\(id)")
}

func resetTotalMsgCounter(id:String){
    UserDefaults.standard.set(0, forKey: "total\(id)")
}

func getTotalMsgCounter(id:String)->Int{
    let counter = UserDefaults.standard.integer(forKey: "total\(id)" )
    
    return counter
}

func removeTotalMsgCounter(id:String){
    UserDefaults.standard.removeObject(forKey: "total\(id)")
}



// MARK: - Chat UnRead Msg
func saveUnReadMsg(value:Int , id:String){
    //    let counter = UserDefaults.standard.integer(forKey: "UnRead\(id)" )
    UserDefaults.standard.set(value, forKey: "UnRead\(id)")
}

func resetUnReadMsg(id:String){
    UserDefaults.standard.set(0, forKey: "UnRead\(id)")
}

func getUnReadMsg(id:String)->Int{
    let counter = UserDefaults.standard.integer(forKey: "UnRead\(id)" )
    
    return counter
}

func setUnReadMsgValue(id:String){
    var counter = UserDefaults.standard.integer(forKey: "UnRead\(id)" )
    
    if counter > 0{
        counter -= 1
        UserDefaults.standard.set(counter, forKey: "UnRead\(id)")
    }
}

func removeUnReadMsg(id:String){
    UserDefaults.standard.removeObject(forKey: "UnRead\(id)")
}

// MARK: - All Chat UnRead Msg
func incrementAllUnRead(value:Int){
    
    let counter = UserDefaults.standard.integer(forKey: "totalUnReadMsg" )
    UserDefaults.standard.set(counter+value, forKey: "totalUnReadMsg")
}

func getAllUnReadMsg()->Int{
    let counter = UserDefaults.standard.integer(forKey: "totalUnReadMsg" )
    return counter
}

func resetAllUnReadMsg(){
    UserDefaults.standard.set(0, forKey: "totalUnReadMsg")
}


func decrementUnReadMsgCounter(value:Int){
    var counter = UserDefaults.standard.integer(forKey: "totalUnReadMsg" )
    counter = counter - value
    UserDefaults.standard.set(counter, forKey: "totalUnReadMsg")
}

func reSetTotalCounter(){
    UserDefaults.standard.set(0, forKey: "totalUnReadMsg")
}




//
//  Constant.swift
//  entourage
//
//  Created by afeef sohail on 7/26/19.
//  Copyright © 2019 West Bay Technologies. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

fileprivate enum Enviroment: String {
    
    case development = "development"
    case production = "production"
    
}

let testPhoneNumber = "+14016010550"
let db = Firestore.firestore()
var chatListener:MessageFirebaseService<ChatMessage>?
var lastMessageListner:unReadMessageFirebaseService<LastMessage>?
var activeMemberListner : ActiveMemberFireBaseService<ActiveMember>?
let statusBar = UIApplication.shared.windows.first?.windowScene?.statusBarManager?.statusBarFrame.height
let screenSize = UIScreen.main.bounds.height + (statusBar ?? 0.0)

//User Defautl Keys
let spotLiteUserDefaultKey = "isSpotLightPopUpShow"
let iMatchUserDefaultKey = "isinstantMatchPopUpShow"
let firstUnLikeSwipe = "FirstUnLikeSwipe"
let firstLikeSwipe = "FirstLikeSwipe"

struct Constants {
    
    //change this line to switch between live and development
    fileprivate static let enviroment = Enviroment.development
    
   static var filterWords: [String] = ["arse","ass","asshole","bastard","bitch","bollocks","child-fucker","crap","cunt","damn","frigger","fuck","goddamn","godsdamn","hell","holy shit","horseshit","Jesus Christ","Jesus", "fuck","Jesus H. Christ","JesusHaroldChrist","Jesus wept","Jesus","MaryandJoseph","Judas Priest","motherfucker","nigga","nigger","prick","shit","bullshit","shitass","slut","sonofabitch", "sonofasmotherlessgoat", "sonofawhore","whore","sweetJesus","twat"]
    
   static var statusBarHeight = UIApplication.shared.statusBarFrame.height
      
    
    static var baseURL: String {
        
        switch enviroment {
        case .production:
            return ""
        case .development:
            return "http://elk.entourage-175085.development.c66.me"
        }
        
    }
    
}

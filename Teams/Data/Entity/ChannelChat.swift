//
//  ChannelChat.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation

struct ChannelChat : Equatable, Identifiable {
    let channelID : Int
    let channelName : String
    let chatID : Int
    let content, createdAt : String
    let files : [String]
    let user : User
    
    var id : Int { return chatID }
}

//
//  ChannelListChat.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import Foundation

struct ChannelListChat : Equatable, Identifiable {
    var channelID : String
    var workspaceID : String
    var channelName : String
    var createdAt : Date
    var user : ChatUserModel?
    var currentChatCreatedAt : Date?
    var lastChatCreatedAt : Date?
    var lastChatUser : String?
    var unreadCount : Int
    
    var id : String { return channelID }
}

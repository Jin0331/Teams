//
//  ChannelChat.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation

struct ChannelChat : Equatable, Identifiable {
    let channelID : String
    let channelName : String
    let chatID : String
    let content, createdAt : String
    let files : [String]
    let user : User
    
    var id : String { return chatID }
}

extension ChannelChat {
    var createdAtToString : String {
        return createdAt.toDateRaw()!.toString(dateFormat: "yy.MM.dd")
    }
    
    var createdAtDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        return formatter.date(from: createdAt)
    }
}

typealias ChannelChatList = [ChannelChat]

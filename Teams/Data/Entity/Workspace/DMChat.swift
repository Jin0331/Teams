//
//  DMChat.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import Foundation

struct DMChat : Equatable, Identifiable {
    let dmID : String
    let roomID : String
    let content : String
    let createdAt : String
    let files : [String]
    let user : User
    
    var id : String { return dmID }
}

extension DMChat {
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

typealias DMChatList = [DMChat]

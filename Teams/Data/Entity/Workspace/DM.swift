//
//  DM.swift
//  Teams
//
//  Created by JinwooLee on 7/5/24.
//

import Foundation

struct DM : Equatable, Identifiable {
    let roomID, createdAt : String
    let user : User
    
    var id : String { return roomID }
}

extension DM {
    
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

typealias DMList = [DM]

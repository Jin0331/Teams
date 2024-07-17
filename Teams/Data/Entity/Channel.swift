//
//  Channel.swift
//  Teams
//
//  Created by JinwooLee on 7/4/24.
//

import Foundation

struct Channel : Equatable, Identifiable {
    let channelID, name, coverImage,ownerID, createdAt, description : String
    
    var id : String { return channelID}
}

extension Channel {
    var coverImageToUrl : URL {
        return URL(string: APIKey.baseURLWithVersion() + coverImage)!
    }
    
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

typealias ChannelList = [Channel]

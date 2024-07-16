//
//  ChannelSpecific.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import Foundation

struct ChannelSpecific : Equatable, Identifiable {
    let channelID, name, coverImage,ownerID, createdAt, description : String
    let channelMembers : UserList
    
    var id : String { return channelID}
}

extension ChannelSpecific {
    var profileImageToUrl : URL {
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
    
    var toChannel : Channel {
        return .init(channelID: channelID,
                     name: name,
                     coverImage: coverImage,
                     ownerID: ownerID,
                     createdAt: createdAt,
                     description: description)
    }
}

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
    var profileImageToUrl : URL {
        return URL(string: APIKey.baseURLWithVersion() + coverImage)!
    }
    
    var createdAtToString : String {
        return createdAt.toDateRaw()!.toString(dateFormat: "yy.MM.dd")
    }
    
    var createdAtDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: createdAt)
    }
}

typealias ChannelList = [Channel]

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

typealias ChannelList = [Channel]

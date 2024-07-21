//
//  ChannelChatUnreadsCount.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import Foundation

struct ChannelChatUnreadsCount : Equatable, Identifiable {
    let channelID : String
    let name : String
    let count : Int
    var id : String { return channelID }
}

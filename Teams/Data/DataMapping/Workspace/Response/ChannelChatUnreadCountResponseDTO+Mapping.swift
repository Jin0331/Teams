//
//  ChannelChatUnreadCountResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import Foundation

struct ChannelChatUnreadCountResponseDTO : Decodable {
    let channel_id : String
    let name : String
    let count : Int
}

extension ChannelChatUnreadCountResponseDTO {
    func toDomain() -> ChannelChatUnreadsCount {
        return .init(channelID: channel_id,
                     name : name,
                     count: count)
    }
}

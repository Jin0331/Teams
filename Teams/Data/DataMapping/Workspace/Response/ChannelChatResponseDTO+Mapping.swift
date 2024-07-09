//
//  ChannelChatResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import Foundation

struct ChannelChatResponseDTO: Decodable {
    let channelID : Int
    let channelName : String
    let chatID : Int
    let content, createdAt : String
    let files : [String]
    let user : WorkspaceUserResponseDTO

    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case channelName
        case chatID = "chat_id"
        case content, createdAt, files, user
    }
}

extension ChannelChatResponseDTO {
    func toDomain() -> ChannelChat {
        return .init(channelID: channelID, channelName: channelName, chatID: chatID, content: content, createdAt: createdAt, files: files, user: user.toDomain())
    }
}

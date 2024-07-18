//
//  DMChatResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import Foundation

struct DMChatResponseDTO : Decodable {
    let dmID : String
    let roomID : String
    let content, createdAt : String
    let files : [String]
    let user : WorkspaceUserResponseDTO

    enum CodingKeys: String, CodingKey {
        case dmID = "dm_id"
        case roomID = "room_id"
        case content, createdAt, files, user
    }
}

extension DMChatResponseDTO {
    func toDomain() -> DMChat {
        return .init(dmID: dmID, roomID: roomID, content: content, createdAt: createdAt, files: files, user: user.toDomain())
    }
}

//
//  DMResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/5/24.
//

import Foundation

struct DMResponseDTO : Decodable {
    let roomID, createdAt : String
    let user : WorkspaceUserResponseDTO
    
    enum CodingKeys : String, CodingKey {
        case roomID = "room_id"
        case createdAt, user
    }
}

extension DMResponseDTO {
    func toDomain() -> DM {
        return .init(roomID: roomID, createdAt: createdAt, user: user.toDomain())
    }
}

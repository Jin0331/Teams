//
//  DMResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/5/24.
//

import Foundation

struct DMResponseDTO : Decodable {
    let roomID, createdAt : String
    let user : UserResponseDTO
    
    enum CodingKeys : String, CodingKey {
        case roomID = "room_id"
        case createdAt, user
    }
}


extension DMResponseDTO {
    struct UserResponseDTO : Decodable {
        let userID, email, nickname, profileImage : String
        
        enum CodingKeys: String, CodingKey {
            case userID = "user_id"
            case email, nickname, profileImage
        }
    }
}

extension DMResponseDTO {
    func toDomain() -> DM {
        return .init(roomID: roomID, createdAt: createdAt, user: user.toDomain())
    }
}

extension DMResponseDTO.UserResponseDTO {
    func toDomain() -> User {
        return .init(userID: userID, email: email, nickname: nickname, profileImage: profileImage)
    }
}

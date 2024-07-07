//
//  WorkspaceUserResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import Foundation

struct WorkspaceUserResponseDTO : Decodable {
    let userID, email, nickname, profileImage : String
    
    enum CodingKeys : String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage
    }
}

extension WorkspaceUserResponseDTO {
    func toDomain() -> User {
        return .init(userID: userID, email: email, nickname: nickname, profileImage: profileImage)
    }
}

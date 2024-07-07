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
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.email = try container.decode(String.self, forKey: .email)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImage = (try? container.decode(String.self, forKey: .profileImage)) ?? ""
    }
}

extension WorkspaceUserResponseDTO {
    func toDomain() -> User {
        return .init(userID: userID, email: email, nickname: nickname, profileImage: profileImage)
    }
}

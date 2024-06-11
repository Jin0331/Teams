//
//  JoinResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import Foundation

struct JoinResponseDTO: Decodable {
    let userID, email, nickname, profileImage: String
    let phone, provider: String?
    let createdAt: String
    let token: TokenDTO

    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, provider, createdAt, token
    }
}

extension JoinResponseDTO {
    struct TokenDTO: Codable {
        let accessToken, refreshToken: String
    }
}

// MARK: - Mappings to Domain
extension JoinResponseDTO {
    func toDomain() -> Join {
        return .init(userID: userID,
                     email: email,
                     nickname: nickname,
                     profileImage: profileImage,
                     phone: phone,
                     provider: provider,
                     createdAt: createdAt,
                     token: token.toDomain())
    }
}

extension JoinResponseDTO.TokenDTO {
    func toDomain() -> Token {
        return .init(accessToken: accessToken, refreshToken: refreshToken)
    }
}

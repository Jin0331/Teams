//
//  ProfileResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 6/18/24.
//

import Foundation

struct ProfileResponseDTO : Decodable {
    let userID, email, nickname, profileImage, phone, provider, createdAt : String
    let sesacCoin : Int
    
    enum CodingKeys : String, CodingKey {
        case userID = "user_id"
        case email, nickname, profileImage, phone, provider, createdAt, sesacCoin
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.userID = try container.decode(String.self, forKey: .userID)
        self.email = try container.decode(String.self, forKey: .email)
        self.nickname = try container.decode(String.self, forKey: .nickname)
        self.profileImage = (try? container.decode(String.self, forKey: .profileImage)) ?? ""
        self.phone = (try? container.decode(String.self, forKey: .phone)) ?? ""
        self.provider = (try? container.decode(String.self, forKey: .provider)) ?? ""
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.sesacCoin = (try? container.decode(Int.self, forKey: .sesacCoin)) ?? 0
    }
}

extension ProfileResponseDTO {
    func toDomain() -> Profile {
        return .init(userID: userID,
                     email: email,
                     nickname: nickname,
                     profileImage: profileImage,
                     phone: phone,
                     provider: provider,
                     createdAt: createdAt,
                     sesacCoin: sesacCoin)
    }
}

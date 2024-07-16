//
//  ChannelSpecificResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import Foundation

struct ChannelSpecificResponseDTO : Decodable {
    let channelID, name, coverImage,ownerID, createdAt, description : String
    let channelMembers : [WorkspaceUserResponseDTO]
    
    enum CodingKeys: String, CodingKey {
        case channelID = "channel_id"
        case name, description, coverImage
        case ownerID = "owner_id"
        case createdAt, channelMembers

    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.channelID = try container.decode(String.self, forKey: .channelID)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = (try? container.decode(String.self, forKey: .description)) ?? ""
        self.coverImage = (try? container.decode(String.self, forKey: .coverImage)) ?? ""
        self.ownerID = try container.decode(String.self, forKey: .ownerID)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.channelMembers = (try? container.decode([WorkspaceUserResponseDTO].self, forKey: .channelMembers)) ?? []
    }
}

extension ChannelSpecificResponseDTO {
    func toDomain() -> ChannelSpecific {
        return .init(channelID: self.channelID,
                     name: self.name,
                     coverImage: self.coverImage,
                     ownerID: self.ownerID,
                     createdAt: self.createdAt,
                     description: self.description,
                     channelMembers: self.channelMembers.map({ user in
            return user.toDomain()
            
        }))
    }
}

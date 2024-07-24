//
//  WorkspaceResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 6/21/24.
//

import Foundation

struct WorkspaceResponseDTO: Decodable {
    let workspaceID, name, description, coverImage: String
    let ownerID, createdAt: String
    let channels : [ChannelResponseDTO]
    let workspaceMembers : [WorkspaceUserResponseDTO]

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case name, description, coverImage
        case ownerID = "owner_id"
        case createdAt, channels, workspaceMembers
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.workspaceID = try container.decode(String.self, forKey: .workspaceID)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = (try? container.decode(String.self, forKey: .description)) ?? ""
        self.coverImage = try container.decode(String.self, forKey: .coverImage)
        self.ownerID = try container.decode(String.self, forKey: .ownerID)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
        self.channels = (try? container.decode([ChannelResponseDTO].self, forKey: .channels)) ?? []
        self.workspaceMembers = (try? container.decode([WorkspaceUserResponseDTO].self, forKey: .workspaceMembers)) ?? []
    }
}

typealias WorkspaceListResponseDTO = [WorkspaceResponseDTO]

extension WorkspaceResponseDTO {
    func toDomain() -> Workspace {
        return .init(workspaceID: workspaceID,
                     name: name,
                     description: description,
                     coverImage: coverImage,
                     ownerID: ownerID,
                     createdAt: createdAt,
                     channels: channels.map({ channel in
                        return channel.toDomain()
                    }),
                     workspacMembers: workspaceMembers.map({ member in
                        return member.toDomain()
                    })
        )
    }
}

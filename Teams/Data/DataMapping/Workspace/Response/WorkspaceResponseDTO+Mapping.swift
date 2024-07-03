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

    enum CodingKeys: String, CodingKey {
        case workspaceID = "workspace_id"
        case name, description, coverImage
        case ownerID = "owner_id"
        case createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.workspaceID = try container.decode(String.self, forKey: .workspaceID)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = (try? container.decode(String.self, forKey: .description)) ?? ""
        self.coverImage = try container.decode(String.self, forKey: .coverImage)
        self.ownerID = try container.decode(String.self, forKey: .ownerID)
        self.createdAt = try container.decode(String.self, forKey: .createdAt)
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
                     createdAt: createdAt)
    }
}

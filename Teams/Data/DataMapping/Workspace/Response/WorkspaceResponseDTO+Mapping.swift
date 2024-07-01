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

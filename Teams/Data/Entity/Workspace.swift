//
//  WorkspaceList.swift
//  Teams
//
//  Created by JinwooLee on 6/21/24.
//

import Foundation

struct Workspace : Equatable, Identifiable {
    let workspaceID, name, description, coverImage: String
    let ownerID, createdAt: String
    
    var id : String { return workspaceID }
}

extension Workspace {
    var profileImageToUrl : URL {
        return URL(string: APIKey.baseURLWithVersion() + coverImage)!
    }
    
    var createdAtToString : String {
        return createdAt.toDateRaw()!.toString(dateFormat: "yy.MM.dd")
    }
}

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
    var coverImageToUrl : URL {
        return URL(string: APIKey.baseURLWithVersion() + coverImage)!
    }
    
    var createdAtToString : String {
        return createdAt.toDateRaw()!.toString(dateFormat: "yy.MM.dd")
    }
    
    var createdAtDate: Date? {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter.date(from: createdAt)
    }
}

typealias WorkspaceList = [Workspace]
extension WorkspaceList {
    func getMostRecentWorkspace(from workspaces: [Workspace]) -> Workspace? {
        return workspaces.sorted(by: {
            ($0.createdAtDate ?? Date.distantPast) > ($1.createdAtDate ?? Date.distantPast)
        }).first
    }
}

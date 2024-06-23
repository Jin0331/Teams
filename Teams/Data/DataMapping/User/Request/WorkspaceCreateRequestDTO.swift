//
//  WorkspaceCreateRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/21/24.
//

import Foundation

struct WorkspaceCreateRequestDTO : Encodable {
    let name : String
    let description : String?
    let image : Data
}

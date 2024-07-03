//
//  WorkspaceRemoveResponseDTO.swift
//  Teams
//
//  Created by JinwooLee on 7/2/24.
//

import Foundation
import Alamofire

struct WorkspaceRemoveResponseDTO : EmptyResponse, Decodable {
    static func emptyValue() -> WorkspaceRemoveResponseDTO {
        return WorkspaceRemoveResponseDTO.init()
        
    }
}

//
//  JoinRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import Foundation

struct JoinRequestDTO : Encodable {
    let email : String
    let password : String
    let nickname : String
    let phone : String
    let deviceToken : String?
}

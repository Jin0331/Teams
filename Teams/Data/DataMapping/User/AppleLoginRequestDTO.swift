//
//  AppleLoginRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/13/24.
//

import Foundation

struct AppleLoginRequestDTO : Encodable {
    let idToken : String
    let nickname : String?
    let deviceToken : String
}

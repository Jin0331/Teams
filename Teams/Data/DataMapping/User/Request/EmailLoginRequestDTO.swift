//
//  EmailLoginRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/13/24.
//

import Foundation

struct EmailLoginRequestDTO : Encodable {
    let email : String
    let password : String
    let deviceToken : String?
}

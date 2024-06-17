//
//  RefreshRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import Foundation

struct RefreshRequestDTO : Encodable {
    let accessToken : String
    let refreshToken : String
}

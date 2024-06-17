//
//  KakaoLoginRequestDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import Foundation

struct KakaoLoginRequestDTO : Encodable {
    let oauthToken : String
    let deviceToken : String
}

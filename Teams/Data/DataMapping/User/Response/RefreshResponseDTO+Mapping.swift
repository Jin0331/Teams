//
//  RefreshResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import Foundation

struct RefreshResponseDTO : Decodable {
    let accessToken : String
}

extension RefreshResponseDTO {
    func toDomain() -> Token {
        return .init(accessToken: accessToken, refreshToken: UserDefaultManager.shared.refreshToken!)
    }
}

//
//  ProfileResponseDTO+Mapping.swift
//  Teams
//
//  Created by JinwooLee on 6/18/24.
//

import Foundation

struct ProfileResponseDTO : Decodable {
    let user_id : String
    let email : String
    let nickname : String
    let profileImage : String?
    let phone : String?
    let provider : String?
    let sesacCoin : Int?
    let createdAt : String
}

//extension ProfileResponseDTO {
//    func toDomain() ->
//}

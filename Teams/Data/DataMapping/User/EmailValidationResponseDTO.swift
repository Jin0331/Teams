//
//  EmailValidationResponseDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import Foundation
import Alamofire

struct EmailVaidationResponseDTO : EmptyResponse, Decodable {
    static func emptyValue() -> EmailVaidationResponseDTO {
        return EmailVaidationResponseDTO.init()
        
    }
}

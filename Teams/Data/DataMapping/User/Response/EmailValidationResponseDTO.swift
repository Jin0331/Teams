//
//  EmailValidationResponseDTO.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import Foundation
import Alamofire

struct EmptyResponseDTO : EmptyResponse, Decodable {
    static func emptyValue() -> EmptyResponseDTO {
        return EmptyResponseDTO.init()
        
    }
}

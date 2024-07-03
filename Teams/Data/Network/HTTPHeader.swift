//
//  HTTPHeader.swift
//  JustBoard
//
//  Created by JinwooLee on 4/9/24.
//

import Foundation

enum HTTPHeader : String {
    case sesacKey = "SesacKey"
    case contentType = "Content-Type"
    case json = "application/json"
    case authorization = "Authorization"
    case refresh = "RefreshToken"
    case multipart = "multipart/form-data"
}

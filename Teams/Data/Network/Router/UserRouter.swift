//
//  UserRouter.swift
//  Teams
//
//  Created by JinwooLee on 6/5/24.
//

import Foundation
import Alamofire

enum UserRouter {
    case emailValidation(query : EmailVaidationRequestDTO)
}

extension UserRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation :
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .emailValidation:
            return "/users/validation/email"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .emailValidation :
            return [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
        }
    }
    
    var parameter: Parameters? {
        return nil
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        
        switch self {
        case let .emailValidation(email):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            return try? encoder.encode(email)
        }
        
        
    }
}


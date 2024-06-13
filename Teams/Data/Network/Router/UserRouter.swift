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
    case join(query : JoinRequestDTO)
    case emailLogin(query : EmailLoginRequestDTO)
    case appleLogin(query : AppleLoginRequestDTO)
}

extension UserRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation, .join, .emailLogin, .appleLogin:
            return .post
        }
    }
    
    var path: String {
        switch self {
        case .emailValidation:
            return "/users/validation/email"
        case .join:
            return "/users/join"
        case .emailLogin:
            return "/users/login"
        case .appleLogin:
            return "/users/login/apple"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .emailValidation , .join, .emailLogin, .appleLogin:
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
            
        case let .join(join):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            return try? encoder.encode(join)
            
        case let .emailLogin(login):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            return try? encoder.encode(login)
            
        case let .appleLogin(login):
            let encoder = JSONEncoder()
            return try? encoder.encode(login)
        }
    }
}


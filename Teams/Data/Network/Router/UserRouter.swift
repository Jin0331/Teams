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
    case kakaoLogin(query : KakaoLoginRequestDTO)
    case refresh(query : RefreshRequestDTO)
    case myProfile
}

extension UserRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .emailValidation, .join, .emailLogin, .appleLogin, .kakaoLogin:
            return .post
        case .refresh, .myProfile:
            return .get
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
        case .kakaoLogin:
            return "/users/login/kakao"
        case .refresh:
            return "/auth/refresh"
        case .myProfile:
            return "/users/me"
        }
    }
    
    var header: [String : String] {
        switch self {
        case .emailValidation , .join, .emailLogin, .appleLogin, .kakaoLogin:
            return [HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
            
        case .refresh(let token):
            return [HTTPHeader.authorization.rawValue : token.accessToken,
                    HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                    HTTPHeader.refresh.rawValue : token.refreshToken
            ]
        case .myProfile:
            guard let token = UserDefaultManager.shared.accessToken else { print("accessToken 없음");return [:] }
            return [HTTPHeader.authorization.rawValue : token,
                    HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
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
            
        case let .kakaoLogin(login):
            let encoder = JSONEncoder()
            return try? encoder.encode(login)
            
        default:
            return nil
        }
    }
}


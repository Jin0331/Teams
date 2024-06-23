//
//  WorkspaceRouter.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import Foundation
import Alamofire

enum WorkspaceRouter {
    case myWorkspaces
}

extension WorkspaceRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .myWorkspaces:
            return .get
        }
    }
    
    var path : String {
        switch self {
        case .myWorkspaces:
            return "/workspaces"
        }
    }
    
    var header: [String : String] {
        guard let token = UserDefaultManager.shared.accessToken else { return [:] }
        
        switch self {
        case .myWorkspaces:
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
        default :
            return nil
        }
    }
}

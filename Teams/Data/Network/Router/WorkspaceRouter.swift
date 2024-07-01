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
    case createWorkspace(request : WorkspaceCreateRequestDTO)
    case removeWorkspace(id : String)
}

extension WorkspaceRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .myWorkspaces:
            return .get
        case .createWorkspace:
            return .post
        case .removeWorkspace:
            return .delete
        }
    }
    
    var path : String {
        switch self {
        case .myWorkspaces, .createWorkspace:
            return "/workspaces"
        case let .removeWorkspace(id):
            return "/workspaces/" + id
        }
    }
    
    var header: [String : String] {
        guard let token = UserDefaultManager.shared.accessToken else { return [:] }
        
        switch self {
        case .myWorkspaces, .createWorkspace, .removeWorkspace:
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
    
    var multipart: MultipartFormData {
        switch self {
        case let .createWorkspace(request):
            let multiPart = MultipartFormData()
            multiPart.append(request.name.data(using: .utf8)!, withName: "name")
            
            if let description = request.description {
                multiPart.append(description.data(using: .utf8)!, withName: "description")
            }
            
            multiPart.append(request.image, withName: "image", fileName: request.name + "_workspaceImage.jpeg", mimeType: "image/jpeg")
            
            return multiPart
            
        default :
            return MultipartFormData()
        }
    }
}

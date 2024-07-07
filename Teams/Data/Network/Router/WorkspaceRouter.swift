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
    case removeWorkspace(request : WorkspaceIDDTO)
    case exitWorkspace(request : WorkspaceIDDTO)
    case editWorkspace(request : WorkspaceIDDTO, body : WorkspaceCreateRequestDTO)
    
    case createChannel(request : WorkspaceIDDTO, body : ChannelCreateRequestDTO)
    
    case myChannels(request : WorkspaceIDDTO)
    case channels(request : WorkspaceIDDTO)
    case dmList(request : WorkspaceIDDTO)
    
}

extension WorkspaceRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .myWorkspaces, .exitWorkspace, .channels, .myChannels, .dmList:
            return .get
        case .createWorkspace, .createChannel:
            return .post
        case .removeWorkspace:
            return .delete
        case .editWorkspace:
            return .put
        }
    }
    
    var path : String {
        switch self {
        case .myWorkspaces, .createWorkspace:
            return "/workspaces"
        case let .removeWorkspace(workspaceID), let .editWorkspace(workspaceID, _):
            return "/workspaces/" + workspaceID.workspace_id
        case let .exitWorkspace(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/exit"
        case let .myChannels(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/my-channels"
        case let .dmList(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/dms"
        case let .createChannel(workspaceID, _), let .channels(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/channels"
        }
    }
    
    var header: [String : String] {
        guard let token = UserDefaultManager.shared.accessToken else { print("accessToken 없음");return [:] }
        
        switch self {
        case .myWorkspaces, .createWorkspace, .removeWorkspace, .exitWorkspace, .editWorkspace, .myChannels, .dmList, .channels:
            return [HTTPHeader.authorization.rawValue : token,
                    HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
            
        case .createChannel:
            return [HTTPHeader.authorization.rawValue : token,
                    HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
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
        case let .createWorkspace(request), let .editWorkspace(_, request):
            let multiPart = MultipartFormData()
            multiPart.append(request.name.data(using: .utf8)!, withName: "name")
            
            if let description = request.description {
                multiPart.append(description.data(using: .utf8)!, withName: "description")
            }
            
            multiPart.append(request.image, withName: "image", fileName: request.name + "_workspaceImage.jpeg", mimeType: "image/jpeg")
            
            return multiPart
            
        case let .createChannel(_, request):
            let multiPart = MultipartFormData()
            multiPart.append(request.name.data(using: .utf8)!, withName: "name")
            
            if let description = request.description {
                multiPart.append(description.data(using: .utf8)!, withName: "description")
            }
            
            if let image = request.image {
                multiPart.append(image, withName: "image", fileName: request.name + "_channelImage.jpeg", mimeType: "image/jpeg")
            }
            
            return multiPart
            
        default :
            return MultipartFormData()
        }
    }
}

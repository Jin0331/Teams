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
    case removeWorkspace(request : WorkspaceIDRequestDTO)
    case exitWorkspace(request : WorkspaceIDRequestDTO)
    case editWorkspace(request : WorkspaceIDRequestDTO, body : WorkspaceCreateRequestDTO)
    case inviteWorkspace(request : WorkspaceIDRequestDTO, body : WorkspaceEmailRequestDTO)
    case workspaceMember(request : WorkspaceIDRequestDTO)
    
    case createChannel(request : WorkspaceIDRequestDTO, body : ChannelCreateRequestDTO)
    case editChannel(request : WorkspaceIDRequestDTO, body : ChannelCreateRequestDTO)
    case exitChannel(request : WorkspaceIDRequestDTO)
    case removeChannel(request : WorkspaceIDRequestDTO)
    
    case myChannels(request : WorkspaceIDRequestDTO)
    case channels(request : WorkspaceIDRequestDTO)
    case specificChannels(request : WorkspaceIDRequestDTO)
    case channelChat(request : WorkspaceIDRequestDTO, query : String)
    case sendChannelChat(request : WorkspaceIDRequestDTO, body : ChannelChatRequestDTO)
    
    case channelMember(request : WorkspaceIDRequestDTO)
    case channelOwnerChange(request : WorkspaceIDRequestDTO, body : ChannelOwnershipRequestDTO)
    
    case dmList(request : WorkspaceIDRequestDTO)
    
}

extension WorkspaceRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .myWorkspaces, .exitWorkspace, .channels, .myChannels, .dmList, .channelChat, .channelMember, .exitChannel, .specificChannels, .workspaceMember:
            return .get
        case .createWorkspace, .createChannel, .inviteWorkspace, .sendChannelChat:
            return .post
        case .removeWorkspace, .removeChannel:
            return .delete
        case .editWorkspace, .editChannel, .channelOwnerChange:
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
        case let .workspaceMember(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/members"
        case let .createChannel(workspaceID, _), let .channels(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/channels"
        case let .inviteWorkspace(workspaceID,_):
            return "/workspaces/" + workspaceID.workspace_id + "/members"
        case let .editChannel(workspaceID, _), let .removeChannel(workspaceID), let .specificChannels(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/channels/" + workspaceID.channel_id
        case let .exitChannel(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/channels/" + workspaceID.channel_id + "/exit"
        case let .channelChat(workspaceID, _), let .sendChannelChat(workspaceID,_):
            return "/workspaces/" + workspaceID.workspace_id + "/channels/" + workspaceID.channel_id + "/chats"
        case let .channelMember(workspaceID):
            return "/workspaces/" + workspaceID.workspace_id + "/channels/" + workspaceID.channel_id + "/members"
        case let .channelOwnerChange(workspaceID, _):
            return "/workspaces/" + workspaceID.workspace_id + "/channels/" + workspaceID.channel_id + "/transfer/ownership"
        }
    }
    
    var header: [String : String] {
        guard let token = UserDefaultManager.shared.accessToken else { print("accessToken 없음");return [:] }
        
        switch self {
        case .myWorkspaces, .createWorkspace, .removeWorkspace, .exitWorkspace, .editWorkspace, .myChannels, .dmList, .channels, .inviteWorkspace, .channelChat, .channelMember, .exitChannel, .removeChannel, .specificChannels, .channelOwnerChange, .workspaceMember:
            return [HTTPHeader.authorization.rawValue : token,
                    HTTPHeader.contentType.rawValue : HTTPHeader.json.rawValue,
                    HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
            
        case .createChannel, .sendChannelChat, .editChannel:
            return [HTTPHeader.authorization.rawValue : token,
                    HTTPHeader.contentType.rawValue : HTTPHeader.multipart.rawValue,
                    HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue]
        }
    }
    
    var parameter: Parameters? {
        switch self {
        case let .channelChat(_, query):
            return ["cursor_date" : query]
        default :
            return nil
        }
    }
    
    var queryItems: [URLQueryItem]? {
        return nil
    }
    
    var body: Data? {
        switch self {
        case let .inviteWorkspace(_,email):
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            
            return try? encoder.encode(email)
        
        case let .channelOwnerChange(_, ownerID):
            let encoder = JSONEncoder()
            return try? encoder.encode(ownerID)

        default :
            return nil
        }
    }
    
    var multipart: MultipartFormData {
        switch self {
        case let .createWorkspace(body), let .editWorkspace(_, body):
            let multiPart = MultipartFormData()
            multiPart.append(body.name.data(using: .utf8)!, withName: "name")
            
            if let description = body.description {
                multiPart.append(description.data(using: .utf8)!, withName: "description")
            }
            
            multiPart.append(body.image, withName: "image", fileName: body.name + "_workspaceImage.jpeg", mimeType: "image/jpeg")
            
            return multiPart
            
        case let .createChannel(_, body), let .editChannel(_, body):
            let multiPart = MultipartFormData()
            multiPart.append(body.name.data(using: .utf8)!, withName: "name")
            
            if let description = body.description {
                multiPart.append(description.data(using: .utf8)!, withName: "description")
            }
            
            if let image = body.image {
                multiPart.append(image, withName: "image", fileName: body.name + "_channelImage.jpeg", mimeType: "image/jpeg")
            }
            
            return multiPart
        
        case let .sendChannelChat(_, body):
            let multiPart = MultipartFormData()
            multiPart.append(body.content.data(using: .utf8)!, withName: "content")
            
            if !body.files.isEmpty {
                body.files.enumerated().forEach { (index, imageURL) in
                    multiPart.append(imageURL, withName: "files", fileName: "file\(index).jpeg", mimeType: "image/jpeg")
                }
            }
            
            return multiPart
            
        default :
            return MultipartFormData()
        }
    }
}

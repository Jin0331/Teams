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
    case sendChannelChat(request : WorkspaceIDRequestDTO, body : ChatRequestDTO)
    case unreadChannelChat(request : WorkspaceIDRequestDTO, query : String)
    
    case channelMember(request : WorkspaceIDRequestDTO)
    case channelOwnerChange(request : WorkspaceIDRequestDTO, body : ChannelOwnershipRequestDTO)
    
    case dmList(request : WorkspaceIDRequestDTO)
    case dmListCreate(request : WorkspaceIDRequestDTO, body : DMListRequestDTO)
    case dmChat(request : WorkspaceIDRequestDTO, query : String)
    case sendDMChat(request : WorkspaceIDRequestDTO, body : ChatRequestDTO)
    case unreadDMChat(request : WorkspaceIDRequestDTO, query : String)
    
}

extension WorkspaceRouter : TargetType {
    var baseURL: URL {
        return URL(string: APIKey.baseURLWithVersion())!
    }
    
    var method: HTTPMethod {
        switch self {
        case .myWorkspaces, .exitWorkspace, .channels, .myChannels, .dmList, .channelChat, .channelMember, .exitChannel, .specificChannels, 
                .workspaceMember, .dmChat, .unreadDMChat, .unreadChannelChat:
            return .get
        case .createWorkspace, .createChannel, .inviteWorkspace, .sendChannelChat, .dmListCreate, .sendDMChat:
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
        case let .dmList(workspaceID), let .dmListCreate(workspaceID, _):
            return "/workspaces/" + workspaceID.workspace_id + "/dms"
        case let .dmChat(workspaceID, _), let .sendDMChat(workspaceID, _):
            return "/workspaces/" + workspaceID.workspace_id + "/dms/" + workspaceID.room_id + "/chats"
        case let .unreadDMChat(workspaceID, _):
            return "/workspaces/" + workspaceID.workspace_id + "/dms/" + workspaceID.room_id + "/unreads"
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
        case let .unreadChannelChat(workspaceID,_):
            return "/workspaces/" + workspaceID.workspace_id + "/channels/" + workspaceID.channel_id + "/unreads"
        }
    }
    
    var header: [String : String] {
        guard let token = UserDefaultManager.shared.accessToken else { print("accessToken 없음");return [:] }
        
        switch self {
        case .myWorkspaces, .createWorkspace, .removeWorkspace, .exitWorkspace, .editWorkspace, .myChannels, .dmList, .channels, .inviteWorkspace, .channelChat, .channelMember, .exitChannel, .removeChannel, .specificChannels, .channelOwnerChange, .workspaceMember, .dmListCreate, .dmChat, .sendDMChat, .unreadDMChat, .unreadChannelChat:
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
        case let .channelChat(_, query), let .dmChat(_, query):
            return ["cursor_date" : query]
        case let .unreadDMChat(_, query), let .unreadChannelChat(_, query):
            return ["after" : query]
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

        case let .dmListCreate(_, opponentID):
            let encoder = JSONEncoder()
            return try? encoder.encode(opponentID)
            
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
        
        case let .sendChannelChat(_, body), let .sendDMChat(_, body):
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

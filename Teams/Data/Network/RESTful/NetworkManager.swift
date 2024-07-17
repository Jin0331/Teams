//
//  NetworkManager.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import Foundation
import ComposableArchitecture
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import Alamofire

final class NetworkManager {

    private func requestAPI<T:Decodable>(router : URLRequestConvertible, of type : T.Type) async throws -> T {
        
        let urlRequest = try router.asURLRequest()
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(urlRequest)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: type, emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case let .success(response):
                        continuation.resume(returning: response)
                    case let .failure(error):
                        
                        if let errorData = response.data {
                            do {
                                let networkError = try JSONDecoder().decode(ErrorResponseDTO.self, from: errorData)
                                let apiError = APIError(error: networkError)
                                continuation.resume(throwing: apiError)
                            } catch {
                                // decoding Error
                                dump(error)
                                continuation.resume(throwing: APIError.decodingError)
                            }
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }
    
    private func requestAPIWithRefresh<T:Decodable>(router : URLRequestConvertible, of type : T.Type) async throws -> T {
        
        let urlRequest = try router.asURLRequest()
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(urlRequest, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: type, emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case let .success(response):
                        continuation.resume(returning: response)
                    case let .failure(error):
                        if let errorData = response.data {
                            do {
                                let networkError = try JSONDecoder().decode(ErrorResponseDTO.self, from: errorData)
                                let apiError = APIError(error: networkError)
                                continuation.resume(throwing: apiError)
                            } catch {
                                // decoding Error
                                dump(error)
                                continuation.resume(throwing: APIError.decodingError)
                            }
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }
    
    private func requestAPIWithRefresh<T:Decodable>(router : URLRequestConvertible, of type : T.Type, multipart : MultipartFormData) async throws -> T {
        
        let urlRequest = try router.asURLRequest()
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.upload(multipartFormData: multipart, to: urlRequest.url!, method: urlRequest.method!, headers: urlRequest.headers, interceptor: AuthManager())
                .validate(statusCode: 200..<300)
                .responseDecodable(of: type, emptyResponseCodes: [200]) { response in
                    switch response.result {
                    case let .success(response):
                        continuation.resume(returning: response)
                    case let .failure(error):
                        
                        if let errorData = response.data {
                            do {
                                let networkError = try JSONDecoder().decode(ErrorResponseDTO.self, from: errorData)
                                let apiError = APIError(error: networkError)
                                continuation.resume(throwing: apiError)
                            } catch {
                                // decoding Error
                                dump(error)
                                continuation.resume(throwing: APIError.decodingError)
                            }
                        } else {
                            continuation.resume(throwing: error)
                        }
                    }
                }
        }
    }
    
    //MARK: - User
    func emailValidation(query : EmailVaidationRequestDTO) async -> Result<EmptyResponseDTO, APIError> {
        do {
            let response = try await requestAPI(router: UserRouter.emailValidation(query: query), of: EmptyResponseDTO.self)
            return .success(response)
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func join(query : JoinRequestDTO) async -> Result<Join, APIError> {
        do {
            let response = try await requestAPI(router: UserRouter.join(query: query), of: JoinResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func emailLogin(query : EmailLoginRequestDTO) async -> Result<Join, APIError> {
        do {
            let response = try await requestAPI(router: UserRouter.emailLogin(query: query), of: JoinResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func appleLogin(query : AppleLoginRequestDTO) async -> Result<Join, APIError> {
        
        do {
            let response = try await requestAPI(router: UserRouter.appleLogin(query: query), of: JoinResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func kakaoLogin(query : KakaoLoginRequestDTO) async -> Result<Join, APIError> {
        
        do {
            let response = try await requestAPI(router: UserRouter.kakaoLogin(query: query), of: JoinResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func kakaoLoginCallBack() async -> Result<OAuthToken, Error>{
        await withCheckedContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                DispatchQueue.main.async {
                    UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                        if let error {
                            continuation.resume(returning: .failure(error))
                        } else if let oauthToken {
                            continuation.resume(returning: .success(oauthToken))
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                        if let error {
                            continuation.resume(returning: .failure(error))
                        } else if let oauthToken {
                            continuation.resume(returning: .success(oauthToken))
                        }
                    }
                }
            }
        }
    }
    
    //MARK: - Workspace
    func getWorkspaceList() async -> Result<[Workspace], APIError> {
        
        do {
            let response = try await requestAPIWithRefresh(router: WorkspaceRouter.myWorkspaces, of: [WorkspaceResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func createWorkspace(query : WorkspaceCreateRequestDTO) async -> Result<Workspace, APIError> {
        
        let router = WorkspaceRouter.createWorkspace(request: query)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: WorkspaceResponseDTO.self, multipart: router.multipart)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func removeWorkspace(query : WorkspaceIDRequestDTO) async -> Result<WorkspaceRemoveResponseDTO, APIError> {
        
        let router = WorkspaceRouter.removeWorkspace(request: query)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: WorkspaceRemoveResponseDTO.self)
            return .success(response)
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func exitWorkspace(query : WorkspaceIDRequestDTO) async -> Result<[Workspace], APIError> {
        
        let router = WorkspaceRouter.exitWorkspace(request: query)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [WorkspaceResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func editWorkspace(request : WorkspaceIDRequestDTO, query : WorkspaceCreateRequestDTO) async -> Result<Workspace, APIError> {
        
        let router = WorkspaceRouter.editWorkspace(request: request, body: query)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: WorkspaceResponseDTO.self, multipart: router.multipart)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func inviteMember(request : WorkspaceIDRequestDTO, query : WorkspaceEmailRequestDTO) async -> Result<User, APIError> {
        do {
            let response = try await requestAPI(router: WorkspaceRouter.inviteWorkspace(request: request, body : query), of: WorkspaceUserResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func getWorkspaceMember(request : WorkspaceIDRequestDTO) async -> Result<UserList, APIError> {
        do {
            let response = try await requestAPI(router: WorkspaceRouter.workspaceMember(request: request), of: [WorkspaceUserResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func getMyChannels(request : WorkspaceIDRequestDTO) async -> Result<ChannelList, APIError> {
        
        let router = WorkspaceRouter.myChannels(request: request)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [ChannelResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func getChannels(request : WorkspaceIDRequestDTO) async -> Result<[Channel], APIError> {
        
        let router = WorkspaceRouter.channels(request: request)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [ChannelResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func getSpecificChannel(request : WorkspaceIDRequestDTO) async -> Result<ChannelSpecific, APIError> {
        let router = WorkspaceRouter.specificChannels(request: request)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: ChannelSpecificResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func getDMList(request : WorkspaceIDRequestDTO) async -> Result<[DM], APIError> {
        
        let router = WorkspaceRouter.dmList(request: request)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [DMResponseDTO].self)

            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func createChannel(request : WorkspaceIDRequestDTO, query : ChannelCreateRequestDTO) async -> Result<Channel, APIError> {
        
        let router = WorkspaceRouter.createChannel(request: request, body: query)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: ChannelResponseDTO.self, multipart: router.multipart)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func editChannel(request : WorkspaceIDRequestDTO, query : ChannelCreateRequestDTO) async -> Result<Channel, APIError> {
        
        let router = WorkspaceRouter.editChannel(request: request, body: query)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: ChannelResponseDTO.self, multipart: router.multipart)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    
    func joinOrSearchChannelChat(request : WorkspaceIDRequestDTO, cursorDate : String) async -> Result<ChannelChatList, APIError> {
        let router = WorkspaceRouter.channelChat(request: request, query: cursorDate)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [ChannelChatResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func sendChannelMessage(request : WorkspaceIDRequestDTO, body : ChannelChatRequestDTO) async -> Result<ChannelChat, APIError> {
        let router = WorkspaceRouter.sendChannelChat(request: request, body: body)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: ChannelChatResponseDTO.self, multipart: router.multipart)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func getChannelMemebers(request : WorkspaceIDRequestDTO) async -> Result<UserList, APIError> {
        
        let router = WorkspaceRouter.channelMember(request: request)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [WorkspaceUserResponseDTO].self)

            return .success(response.map({ dto in
                
                print(dto)
                
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func removeChannel(request : WorkspaceIDRequestDTO) async -> Result<EmptyResponseDTO, APIError> {
        do {
            let response = try await requestAPI(router: WorkspaceRouter.removeChannel(request: request), of: EmptyResponseDTO.self)
            return .success(response)
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func exitChannel(request : WorkspaceIDRequestDTO) async -> Result<ChannelList, APIError> {
        
        let router = WorkspaceRouter.exitChannel(request: request)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: [ChannelResponseDTO].self)
            return .success(response.map({ dto in
                return dto.toDomain()
            }))
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
    func changeChannelOwner(request : WorkspaceIDRequestDTO, body : ChannelOwnershipRequestDTO) async -> Result<Channel, APIError> {
        
        let router = WorkspaceRouter.channelOwnerChange(request: request, body: body)
        
        do {
            let response = try await requestAPIWithRefresh(router: router, of: ChannelResponseDTO.self)
            return .success(response.toDomain())
        } catch {
            if let apiError = error as? APIError {
                return .failure(apiError)
            } else {
                return .failure(APIError.unknown)
            }
        }
    }
    
}


private enum NetworkManagerKey: DependencyKey {
    static var liveValue: NetworkManager = NetworkManager()
}

extension DependencyValues {
    var networkManager: NetworkManager {
        get { self[NetworkManagerKey.self] }
        set { self[NetworkManagerKey.self] = newValue }
    }
}


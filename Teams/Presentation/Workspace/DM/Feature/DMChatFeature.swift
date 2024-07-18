//
//  DMChatFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/18/24.
//

import ComposableArchitecture
import Foundation
import Alamofire
import ExyteChat
import RealmSwift

@Reducer
struct DMChatFeature {
    
    @ObservedResults(DMChatModel.self) var chatTable
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var roomCurrent : DM
        var message : [Message] = []
    }
    
    enum Action {
        case onAppear
        case sendMessage(DraftMessage)
        case socket(SocketAction)
        case networkResponse(NetworkResponse)
        case goBack
    }
    
    enum NetworkResponse {
        case dmChatResponse(Result<[DMChat], APIError>)
        case dmSendChatResponse(Result<DMChat, APIError>)
    }
    
    enum SocketAction {
        case socketConnect
        case socketReceive
        case socketDisconnectAndGoback
        case socketDisconnectAndGoChannelSetting
        case socketRecevieHandling(DMChat)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.realmRepository) var realmRepository
    @Dependency(\.socketManager) var socketManager
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard let workspace = state.workspaceCurrent else { return .none }
                let cursorDate = realmRepository.fetchDMChatLastDate(roomID: state.roomCurrent.roomID) ?? Date()
                
                realmRepository.realmLocation()
                print("🌟🌟🌟🌟🌟🌟🌟\nworkspaceID 🌟 : \(workspace.id)\nchannelID 🌟 : \(state.roomCurrent.roomID)\nToken 🌟 : \(UserDefaultManager.shared.accessToken!)\nSecretKey 🌟 : \(APIKey.secretKey.rawValue)\n🌟🌟🌟🌟🌟🌟🌟")
    
                return .run { [room = state.roomCurrent] send in
                    
                    let workspaceIDDTO = WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: room.roomID)
                    
                    await send(.networkResponse(.dmChatResponse(
                        networkManager.getDMChat(request: workspaceIDDTO, cursorDate: cursorDate.toStringRaw())
                    )))
                }
            
            case let .sendMessage(sendMessage):
                
                guard let workspace = state.workspaceCurrent else { return .none }
                if sendMessage.text.isEmpty && sendMessage.medias.isEmpty {
                    print("sendmessage is empty 🥲")
                    return .none
                } else {
                    return .run { [room = state.roomCurrent.roomID] send in
                        var files : [URL] = []
                        
                        if !sendMessage.medias.isEmpty {
                            for image in sendMessage.medias {
                                if let fileURL = await image.getURL() {
                                    files.append(fileURL)
                                }
                            }
                            await send(.networkResponse(.dmSendChatResponse(
                                networkManager.sendDMMessage(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: room),
                                                             body: ChatRequestDTO(content: sendMessage.text, files: files)))))
                        } else {
                            await send(.networkResponse(.dmSendChatResponse(
                                networkManager.sendDMMessage(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: room),
                                                             body: ChatRequestDTO(content: sendMessage.text, files: [])))))

                        }
                    }
                }
                
            case let .networkResponse(.dmChatResponse(.success(dmList))):
                
                // 최신 채팅 업데이트
                if !dmList.isEmpty {
                    dmList.forEach { chat in
                        $chatTable.append(DMChatModel(from: DMChat(dmID: chat.dmID,
                                                                   roomID: chat.roomID,
                                                                   content: chat.content,
                                                                   createdAt: chat.createdAt,
                                                                   files: chat.files,
                                                                   user: chat.user)))
                    }
                } else {
                    print("최신 채팅 없음 ✅")
                }
                
                //TODO: - Realm으로부터 message 조회
                state.message = realmRepository.fetchDMExyteMessage(roomID: state.roomCurrent.roomID)
                
                return .send(.socket(.socketConnect))
                
            case let .networkResponse(.dmChatResponse(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
            case .socket(.socketConnect):
                return .run { [ roomID = state.roomCurrent.roomID ] send in
                    
                    let socketStream = await socketManager.connect(to: .dmsChat(roomID: roomID), type: DMChatResponseDTO.self)
                    for await stream in socketStream {
                        switch stream {
                        case let .success(response):
                            await send(.socket(.socketRecevieHandling(response.toDomain())))
                        case let .failure(error):
                            let errorType = APIError.networkErrorType(error: error.errorDescription)
                            print(errorType, error)
                        }
                    }
                }
                
            case let .socket(.socketRecevieHandling(chat)):                
                let chat = DMChatModel(from: DMChat(dmID: chat.dmID,
                                                         roomID: chat.roomID,
                                                         content: chat.content,
                                                         createdAt: chat.createdAt,
                                                         files: chat.files,
                                                         user: chat.user))
                
                $chatTable.append(chat)
                state.message.append(chat.toMessage().toExyteMessage())

                return .none

            case .socket(.socketDisconnectAndGoback):
                socketManager.stopAndRemoveSocket()
                return .send(.goBack)
                
            default :
                return .none

            }
        }
    }
}

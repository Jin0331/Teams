//
//  ChannelChatFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import ComposableArchitecture
import Foundation
import Alamofire
import ExyteChat
import RealmSwift

@Reducer
struct ChannelChatFeature {
    
    @ObservedResults(ChannelChatModel.self) var chatTable
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelCurrent : Channel
        var channelCurrentMembers : UserList = []
        var message : [Message] = []
    }
    
    enum Action  {
        case onAppear
        case sendMessage(DraftMessage)
        case channelChatResponse(Result<[ChannelChat], APIError>)
        case channelSendChatResponse(Result<ChannelChat, APIError>)
        case channelMembersResponse(Result<UserList, APIError>)
        case socket(SocketAction)
        case goBack
        case goChannelSetting((currentWorksapce : Workspace?, currentChannel : Channel, currentChannelMembers : UserList))
    }
    
    enum SocketAction {
        case socketConnect
        case socketReceive
        case socketDisconnectAndGoback
        case socketDisconnectAndGoChannelSetting
        case socketRecevieHandling(ChannelChat)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.realmRepository) var realmRepository
    @Dependency(\.socketManager) var socketManager
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
                let cursorDate = realmRepository.fetchChannelChatLastDate(channelID: state.channelCurrent.id) ?? Date()
                
                return .run { [channel = state.channelCurrent] send in
                    
                    let workspaceIDDTO = WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id, room_id: "")
                    
                    await send(.channelMembersResponse(
                        networkManager.getChannelMemebers(request: workspaceIDDTO)
                    ))
                    
                    await send(.channelChatResponse(
                        networkManager.joinOrSearchChannelChat(request: workspaceIDDTO, cursorDate: cursorDate.toStringRaw())
                    ))
                }
            
            case let .channelMembersResponse(.success(members)):
                state.channelCurrentMembers = members
                return .none
                
            case let .channelChatResponse(.success(chatList)):
                
                // 최신 채팅 업데이트
                if !chatList.isEmpty {
                    chatList.forEach { chat in
                        $chatTable.append(ChannelChatModel(from: ChannelChat(channelID: chat.channelID,
                                                                             channelName: chat.channelName,
                                                                             chatID: chat.chatID,
                                                                             content: chat.content,
                                                                             createdAt: chat.createdAt,
                                                                             files: chat.files,
                                                                             user: chat.user)))
                    }
                } else {
                    print("최신 채팅 없음 ✅")
                }
                
                //TODO: - Realm으로부터 message 조회
                state.message = realmRepository.fetchChannelExyteMessage(channelID: state.channelCurrent.id)
                
                return .send(.socket(.socketConnect))
            
                
            case let .channelChatResponse(.failure(error)), let .channelSendChatResponse(.failure(error)), let .channelMembersResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
            case let .sendMessage(sendMessage):
                
                guard let workspace = state.workspaceCurrent else { return .none }
                if sendMessage.text.isEmpty && sendMessage.medias.isEmpty {
                    print("sendmessage is empty 🥲")
                    return .none
                } else {
                    return .run { [channel = state.channelCurrent] send in
                        var files : [URL] = []
                        
                        if !sendMessage.medias.isEmpty {
                            for image in sendMessage.medias {
                                if let fileURL = await image.getURL() {
                                    files.append(fileURL)
                                }
                            }
                            await send(.channelSendChatResponse(
                                networkManager.sendChannelMessage(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id, room_id: ""), body: ChatRequestDTO(content: sendMessage.text, files: files))))
                        } else {
                            await send(.channelSendChatResponse(
                                networkManager.sendChannelMessage(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id, room_id: ""), body: ChatRequestDTO(content: sendMessage.text, files: []))))

                        }
                    }
                }
                
            case .socket(.socketConnect):
                return .run { [ channelID = state.channelCurrent.channelID ] send in
                    
                    let socketStream = await socketManager.connect(to: .channelChat(channelID: channelID), type: ChannelChatResponseDTO.self)
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
                
                print(chat)
                
                let chat = ChannelChatModel(from: ChannelChat(channelID: chat.channelID,
                                                              channelName: chat.channelName,
                                                              chatID: chat.chatID,
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
                
            case .socket(.socketDisconnectAndGoChannelSetting):
                socketManager.stopAndRemoveSocket()
                return .none
            
            default :
                return .none
            }
        }
    }
    
}

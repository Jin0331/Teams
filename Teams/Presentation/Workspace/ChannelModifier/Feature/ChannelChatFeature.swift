//
//  ChannelChatFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import ComposableArchitecture
import Foundation
import RealmSwift
import Alamofire
import ExyteChat
import SocketIO

@Reducer
struct ChannelChatFeature {
    
    @ObservedResults(ChannelChatModel.self) var chatTable
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelCurrent : Channel
        var message : [Message] = []
        var manager : SocketManager
        var socket : SocketIOClient
    }
    
    enum Action  {
        case onAppear
        case sendMessage(DraftMessage)
        case channelChatResponse(Result<[ChannelChat], APIError>)
        case socketConnect
        case socketReceive
        case socketDisconnect
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.realmRepository) var realmRepository
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
  
                //TODO: - Realm 연결을 통해 가장 마지막 cusur date 추출해야됨
                
                realmRepository.realmLocation()
                print("🌟🌟🌟🌟🌟🌟🌟\nworkspaceID 🌟 : \(workspace.id)\nchannelID 🌟 : \(state.channelCurrent.channelID)\nToken 🌟 : \(UserDefaultManager.shared.accessToken!)\nSecretKey 🌟 : \(APIKey.secretKey.rawValue)\n🌟🌟🌟🌟🌟🌟🌟")
                
                
                let cursorDate = realmRepository.fetchChatLastDate(channelID: state.channelCurrent.id) ?? Date()
                
                
                return .run { [channel = state.channelCurrent] send in
                    await send(.channelChatResponse(
                        networkManager.joinOrSearchChannelChat(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: channel.id), query: cursorDate.toStringRaw())
                    ))
                }
                
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
                state.message = realmRepository.fetchExyteMessage(channelID: state.channelCurrent.id)
                
                return .send(.socketConnect)
                
            case let .channelChatResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
            
            case let .sendMessage(sendMessage):
                
                print(sendMessage)
                
                return .none
            
            case .socketConnect:
                state.socket.connect()
                return .send(.socketReceive)
            
            case .socketReceive:
                state.socket.on(clientEvent: .connect) { data, ack in
                    print("socket connected", data, ack)
                }
                
                state.socket.on(clientEvent: .disconnect) { data, ack in
                    print("socket disconnected")
                }
                
                state.socket.on("channel") { dataArray, ack in
                    if let data = dataArray.first {
                        
                        do {
                            let result = try JSONSerialization.data(withJSONObject: data)
                            let decodedData = try JSONDecoder().decode(ChannelChatResponseDTO.self, from: result)
                            let chat = decodedData.toDomain()
                            
                            $chatTable.append(ChannelChatModel(from: ChannelChat(channelID: chat.channelID,
                                                                                 channelName: chat.channelName,
                                                                                 chatID: chat.chatID,
                                                                                 content: chat.content,
                                                                                 createdAt: chat.createdAt,
                                                                                 files: chat.files,
                                                                                 user: chat.user)))
                            
//                            state.message = realmRepository.fetchExyteMessage(channelID: state.channelCurrent.id)
                            
                        } catch { }
                    }
                }
                
                return .none
                
            case .socketDisconnect:
                state.socket.disconnect()
                return .none
            }
        }
    }
    
}

//
//  HomeFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import ComposableArchitecture
import RealmSwift
import SwiftUI

@Reducer
struct HomeFeature {
    
    @ObservedResults(DMChatListModel.self) var chatListTable
    @ObservedResults(ChannelChatListModel.self) var channelChatListTable
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelList : ChannelList = []
        var dmList : DMList = []
        var showingChannelActionSheet : Bool = false
        var channelListExpanded : Bool = true
        var dmlListExpanded : Bool = true
        var profileImage : URL?
    }
    
    enum Action : BindableAction{
        case onAppear
        case openSideMenu
        case closeSideMenu
        case channelEnter(Channel)
        case dmListEnter(DM)
        case buttonTapped(ButtonTapped)
        case networkResponse(NetworkResponse)
        case binding(BindingAction<State>)
        case timoerOn(Workspace)
        case timerOff
    }
    
    enum ButtonTapped {
        case channelAddButtonTapped
        case channelCreateButtonTapped
        case channelSearchButtonTapped
        case inviteMemberButtonTapped
        case dmUserButtonTapped(String)
        case profileOpenTapped
        case newMessageButtonTapped
    }
    
    enum NetworkResponse {
        case myProfile(Result<Profile, APIError>)
        case channeListResponse(Result<ChannelList, APIError>)
        case channelChatResponse([ChannelChatList])
        case dmListResponse(Result<DMList, APIError>)
        case dmResponse(Result<DM, APIError>)
        case dmChatResponse([DMChatList])
    }
    
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.realmRepository) var realmRepository
    @Dependency(\.utilitiesFunction) var utils
    @Dependency(\.continuousClock) var clock
    
    var body : some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
                
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
                realmRepository.realmLocation()
                return .merge([
                    .run { send in
                        await send(.networkResponse(.myProfile(
                            networkManager.getMyProfile()
                        )))
                    },
                    .run { send in
                        await send(.networkResponse(.channeListResponse(networkManager.getMyChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: "")))))
                    },
                    .run { send in
                        await send(.networkResponse(.dmListResponse(networkManager.getDMList(request: WorkspaceIDRequestDTO(workspace_id: workspace.workspaceID, channel_id: "", room_id: "")))))
                    },
                    .send(.timoerOn(workspace))
                ])
                
            case let .timoerOn(workspace):
                return .run { send in
                    for await _ in await clock.timer(interval: .seconds(10)) {
                        print("Timer On - HomeView 🌟")
                        await send(.networkResponse(.channeListResponse(networkManager.getMyChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: "")))))
                        await send(.networkResponse(.dmListResponse(networkManager.getDMList(request: WorkspaceIDRequestDTO(workspace_id: workspace.workspaceID, channel_id: "", room_id: "")))))
                    }
                }
                .cancellable(id: CancelID.timer)
                
            case .timerOff :
                print("Timer Off - HomeView 🌟")
                return .cancel(id: CancelID.timer)
                
            case let .networkResponse(.channeListResponse(.success(channelList))):
                guard let currentWorkspace = state.workspaceCurrent else { return .none }
                
                if !channelList.isEmpty {
                    channelList.forEach { channel in
                        realmRepository.upsertChannelList(channelResponse: channel, workspaceID: currentWorkspace.workspaceID)
                        let chatLastChatDate = realmRepository.fetchChannelChatLastDate(channelID: channel.channelID)
                        realmRepository.upsertChannelListLastChatCreatedAt(channelID: channel.channelID, lastChatCreatedAt: chatLastChatDate)
                    }
                } else { return .none}
                
                return .run { send in
                    await send(.networkResponse(.channelChatResponse(try await networkManager.getChannelChatList(workspaceID: currentWorkspace.workspaceID, channelList: channelList))))
                }
                
            case let .networkResponse(.channelChatResponse(channelChatList)):
                guard let currentWorkspace = state.workspaceCurrent else { return .none }
                
                for list in channelChatList {
                    if let lastChat = list.last {
                        realmRepository.upsertCurrentChannelListContentWithCreatedAt(channelID: lastChat.channelID,
                                                                                     currentChatCreatedAt: lastChat.createdAtDate,
                                                                                     lastChatUser: lastChat.user.userID
                        )
                        
                        if let lastChatUser = realmRepository.fetchChannelListChatUser(channelID: lastChat.channelID), lastChatUser == UserDefaultManager.shared.userId! {
                            realmRepository.upsertChannelUnreadsCount(channelID: lastChat.channelID, unreadCount: 0)
                        } else {
                            let after = realmRepository.fetchChannelChatLastDate(channelID: lastChat.channelID) ?? Date()
                            Task {
                                let unreadCountResponse = await networkManager.getUnreadChannelChat(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: lastChat.channelID, room_id: ""), after: after.toStringRaw())
                                if case let .success(response) = unreadCountResponse {
                                    realmRepository.upsertChannelUnreadsCount(channelID: lastChat.channelID, unreadCount: response.count)
                                }
                            }
                        }
                    }
                }
                
                return .none
                
            case let .networkResponse(.myProfile(.success(myProfile))):
                state.profileImage = myProfile.profileImageToUrl
                
                return .none
                
            case let .networkResponse(.channeListResponse(.failure(error))), let .networkResponse(.myProfile(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
                
            case let .networkResponse(.dmListResponse(.failure(error))):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                if case .E13 = errorType {
                    state.dmList = []
                }
                
                return .none
                
            case .buttonTapped(.channelAddButtonTapped):
                state.showingChannelActionSheet = true
                return .none
                
            case let .buttonTapped(.dmUserButtonTapped(user)):
                guard let currentWorkspace = state.workspaceCurrent else { return .none }
                return .run { send in
                    await send(.networkResponse(.dmResponse(
                        networkManager.getOrCreateDMList(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: ""),
                                                         body: DMListRequestDTO(opponent_id: user))
                    )))
                }
                
            case let .networkResponse(.dmResponse(.success(dm))):
                return .send(.dmListEnter(dm))
                
                
                //TODO: - 채팅 내용 조회, 읽지 않은 DM 갯수 조회 Realm Table 구성해야됨
            case let .networkResponse(.dmListResponse(.success(dmList))):
                
                guard let currentWorkspace = state.workspaceCurrent else { return .none }
                
                // DM list 생성
                if !dmList.isEmpty {
                    dmList.forEach { chat in
                        realmRepository.upsertDMList(dmResponse: chat, workspaceID: currentWorkspace.workspaceID)
                        let chatLastChatDate = realmRepository.fetchDMChatLastDate(roomID: chat.roomID)
                        realmRepository.upsertDMListLastChatCreatedAt(roomID: chat.roomID, lastChatCreatedAt: chatLastChatDate)
                    }
                } else { return .none }
                
                return .run { send in
                    await send(.networkResponse(.dmChatResponse(try await networkManager.getDMChatList(workspaceID: currentWorkspace.id, dmlist: dmList))))
                }
                
            case let .networkResponse(.dmChatResponse(dmChatList)):
                
                guard let currentWorkspace = state.workspaceCurrent else { return .none }
                
                for list in dmChatList {
                    if let lastChat = list.last {
                        realmRepository.upsertCurrentDMListContentWithCreatedAt(roomID: lastChat.roomID,
                                                                                content: lastChat.content,
                                                                                currentChatCreatedAt: lastChat.createdAtDate,
                                                                                lastChatUser: lastChat.user.userID
                        )
                        
                        if let lastChatUser = realmRepository.fetchDMListChatUser(roomID: lastChat.roomID), lastChatUser == UserDefaultManager.shared.userId! {
                            realmRepository.upsertDMUnreadsCount(roomID: lastChat.roomID, unreadCount: 0)
                        } else {
                            let after = realmRepository.fetchDMChatLastDate(roomID: lastChat.roomID) ?? Date()
                            Task {
                                let unreadCountResponse = await networkManager.getUnreadDMChat(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: lastChat.roomID), after: after.toStringRaw())
                                if case let .success(response) = unreadCountResponse {
                                    realmRepository.upsertDMUnreadsCount(roomID: lastChat.roomID, unreadCount: response.count)
                                }
                            }
                        }
                    }
                }
                
                return .none
                
            default :
                return .none
            }
            
        }
    }
}

extension HomeFeature {
    enum CancelID {
        case timer
    }
}

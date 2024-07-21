//
//  DMListFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import Foundation
import ComposableArchitecture
import RealmSwift

@Reducer
struct DMListFeature {
    
    @ObservedResults(DMChatListModel.self) var chatListTable
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentWorkspace : Workspace?
        var workspaceMember : UserList = []
        var dmChatList : [DMListChat] = []
        var viewType : DMlistViewType = .loading
    }
    
    enum Action {
        case onAppear
        case networkResponse(NetworkResponse)
        case buttonTapped(ButtonTapped)
        case dmListEnter(DM)
        case dmListUpdate
    }
    
    enum ButtonTapped {
        case inviteMemberButtonTapped
        case dmUserButtonTapped(String)
    }
    
    enum NetworkResponse {
        case workspaceMembersResponse(Result<UserList, APIError>)
        case dmListResponse(Result<DMList, APIError>)
        case dmResponse(Result<DM, APIError>)
        case dmChatResponse([DMChatList])
    }
    
    @Dependency(\.realmRepository) var realmRepository
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
            case .onAppear:
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                realmRepository.realmLocation()
                return .run { send in
                    await send(.networkResponse(.workspaceMembersResponse(
                        networkManager.getWorkspaceMember(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: "")))
                    ))
                }
            
            case let .buttonTapped(.dmUserButtonTapped(user)):
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                return .run { send in
                    await send(.networkResponse(.dmResponse(
                        networkManager.getOrCreateDMList(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: ""),
                                                         body: DMListRequestDTO(opponent_id: user))
                    )))
                }
                
            
            case let .networkResponse(.workspaceMembersResponse(.success(member))):
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                state.workspaceMember = member.filter {
                    $0.userID != UserDefaultManager.shared.userId!
                }
                
                if state.workspaceMember.count < 1 {
                    state.viewType = .empty
                    return .none
                } else {
                    state.viewType = .normal
                    return .run { send in
                        await send(.networkResponse(.dmListResponse(
                            networkManager.getDMList(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: ""))
                        )))
                    }
                }
            //TODO: - 채팅 내용 조회, 읽지 않은 DM 갯수 조회 Realm Table 구성해야됨 
            case let .networkResponse(.dmListResponse(.success(dmList))):
                    
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                
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
                
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                
                for list in dmChatList {
                    if let lastChat = list.last {
                        realmRepository.upsertCurrentDMListContentWithCreatedAt(roomID: lastChat.roomID,
                                                                                content: lastChat.content,
                                                                                currentChatCreatedAt: lastChat.createdAtDate)
                        
                        let after = realmRepository.fetchDMChatLastDate(roomID: lastChat.roomID) ?? Date()
                        
                        Task {
                            let unreadCountResponse = await networkManager.getUnreadDMChat(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "", room_id: lastChat.roomID), after: after.toStringRaw())
                            if case let .success(response) = unreadCountResponse {
                                realmRepository.upsertDMUnreadsCount(roomID: lastChat.roomID, unreadCount: response.count)
                            }
                        }
                    }
                }
                
                return .send(.dmListUpdate)
            
            case .dmListUpdate:
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                state.dmChatList = realmRepository.fetchAllDMChatList(workspaceID: currentWorkspace.workspaceID)
                
                print(state.dmChatList)
                
                return .none
            
            case let .networkResponse(.dmResponse(.success(dm))):
                return .send(.dmListEnter(dm))
                
            case let .networkResponse(.workspaceMembersResponse(.failure(error))), let .networkResponse(.dmListResponse(.failure(error))),
                let .networkResponse(.dmResponse(.failure(error))):
                
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ error")
                return .none
                
                
            default :
                return .none
            }
        }
    }
}

extension DMListFeature {
    enum DMlistViewType {
        case loading
        case empty
        case normal
    }
    

//    private func getDMUnreadChatCount(workspaceID : String, dmList : DMList) async throws -> [DMChatUnreadsCount] {
//        var dmUnreadChatCount : [DMChatUnreadsCount] = []
//        try await withThrowingTaskGroup(of: DMChatUnreadsCount.self) { group in
//            for dm in dmList {
//                group.addTask {
//                    
//                    let dmUnreadCount = await networkManager.getUnreadDMChat(request: WorkspaceIDRequestDTO(workspace_id: workspaceID, channel_id: "", room_id: dm.roomID), after: "")
//                    
//                    if case let .success(dmCount) = dmUnreadCount {
//                        return dmCount
//                    } else {
//                        return DMChatUnreadsCount(roomID: dm.roomID, count: 0)
//                    }
//                }
//                
//                for try await g in group {
//                    dmUnreadChatCount.append(g)
//                }
//            }
//        }
//        return dmUnreadChatCount
//    }
}

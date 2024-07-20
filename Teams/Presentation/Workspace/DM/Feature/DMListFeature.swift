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
        var viewType : DMlistViewType = .loading
    }
    
    enum Action {
        case onAppear
        case networkResponse(NetworkResponse)
        case buttonTapped(ButtonTapped)
        case dmListEnter(DM)
    }
    
    enum ButtonTapped {
        case inviteMemberButtonTapped
        case dmUserButtonTapped(User)
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
                                                         body: DMListRequestDTO(opponent_id: user.userID))
                    )))
                }
                
            
            case let .networkResponse(.workspaceMembersResponse(.success(member))):
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                state.workspaceMember = member
                
                if state.workspaceMember.count < 2 {
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
                        realmRepository.upsertDMList(dmResponse: chat)
                        let chatLastChatDate = realmRepository.fetchDMChatLastDate(roomID: chat.roomID)
                        realmRepository.upsertDMListLastChatCreatedAt(roomID: chat.roomID, lastChatCreatedAt: chatLastChatDate)
                    }
                } else { return .none }
                
                return .run { send in
                    await send(.networkResponse(.dmChatResponse(try await getDMChatList(workspaceID: currentWorkspace.id, dmlist: dmList))))
                }
                
            case let .networkResponse(.dmChatResponse(dmChatList)):
                dmChatList.forEach { list in
                    print(list.last)
                }
                
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
    
    private func getDMChatList(workspaceID : String , dmlist : DMList) async throws -> [DMChatList] {
        var dmChatList : [DMChatList] = []
        try await withThrowingTaskGroup(of: DMChatList.self) { group in
            for dm in dmlist {
                group.addTask {
                    let dm = await networkManager.getDMChat(request: WorkspaceIDRequestDTO(workspace_id: workspaceID, channel_id: "", 
                                                                                           room_id: dm.roomID),
                                                            cursorDate: "")
                    
                    if case let .success(response) = dm {
                        return response
                    } else {
                        return []
                    }
                }
                
                for try await chatList in group {
//                    dmChatList.append(contentsOf: chatList)
                    dmChatList.append(chatList)
                }
            }
        }
        
        return dmChatList
    }
}

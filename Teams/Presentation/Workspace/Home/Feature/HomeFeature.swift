//
//  HomeFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelList : ChannelList = []
        var dmList : DMList = []
        var showingChannelActionSheet : Bool = false
        var channelListExpanded : Bool = true
        var dmlListExpanded : Bool = true
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
    }
    
    enum ButtonTapped {
        case channelAddButtonTapped
        case channelCreateButtonTapped
        case channelSearchButtonTapped
        case inviteMemberButtonTapped
        case dmUserButtonTapped(String)
    }
    
    enum NetworkResponse {
        case channeListlResponse(Result<[Channel], APIError>)
        case dmListResponse(Result<[DM], APIError>)
        case dmResponse(Result<DM, APIError>)
    }
    
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utils
    
    var body : some ReducerOf<Self> {
        
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
            
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
                return .merge([
                    .run { send in
                        await send(.networkResponse(.channeListlResponse(networkManager.getMyChannels(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: "")))))
                    },
                    .run { send in
                        await send(.networkResponse(.dmListResponse(networkManager.getDMList(request: WorkspaceIDRequestDTO(workspace_id: workspace.id, channel_id: "", room_id: "")))))
                    }
                ])
                
            case let .networkResponse(.channeListlResponse(.success(response))):
                state.channelList = utils.getSortedChannelList(from: response)
                
                return .none
                
            case let .networkResponse(.dmListResponse(.success(response))):
                
                return .none

                
            case let .networkResponse(.channeListlResponse(.failure(error))):
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
                
            default :
                return .none
            }
                
        }
    }
}

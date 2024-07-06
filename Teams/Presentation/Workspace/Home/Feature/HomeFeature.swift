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
    }

    enum Action {
        case onAppear
        case openSideMenu
        case closeSideMenu
        case channelCreateButtonTapped
        
        case channeListlResponse(Result<[Channel], APIError>)
        case dmListResponse(Result<[DM], APIError>)
        
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utils
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
                
                print(workspace.id, UserDefaultManager.shared.accessToken)
                
                return .merge([
                    .run { send in
                        await send(.channeListlResponse(networkManager.getMyChannels(request: WorkspaceIDDTO(workspace_id: workspace.id))))
                    },
                    .run { send in
                        await send(.dmListResponse(networkManager.getDMList(request: WorkspaceIDDTO(workspace_id: workspace.id))))
                    }
                ])
                
            case let .channeListlResponse(.success(response)):
                state.channelList = utils.getSortedChannelList(from: response)
                
                return .none
                
            case let .dmListResponse(.success(response)):
                
                return .none

                
            case let .channeListlResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
                
            case let .dmListResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                if case .E13 = errorType {
                    state.dmList = []
                }
                
                return .none
                
            default :
                return .none
            }
                
        }
    }
}

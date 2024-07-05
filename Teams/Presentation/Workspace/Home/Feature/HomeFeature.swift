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
    }

    enum Action {
        case onAppear
        case openSideMenu
        case closeSideMenu
        case myChannelResponse(Result<[Channel], APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            
            case .onAppear :
                
                guard let workspace = state.workspaceCurrent else { return .none }
                
                return .run { send in
                    await send(.myChannelResponse(
                        networkManager.getMyChannels(request: WorkspaceIDDTO(workspace_id: workspace.id))
                    ))
                }
                
            case let .myChannelResponse(response):
                print(response)
                
                return .none
                
            default :
                return .none
            }
                
        }
    }
}

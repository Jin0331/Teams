//
//  ChannelSearchFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ChannelSearchFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelList : ChannelList = []
        var myChannelList : ChannelList = []
    }
    
    enum Action : Equatable {
        case dismiss
        case onAppear
        case channeListlResponse(Result<[Channel], APIError>)
        case myChanneListlResponse(Result<[Channel], APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utils
    
    var body : some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            case .onAppear :
                guard let workspace = state.workspaceCurrent else { return .none }
                
                print(workspace.id, UserDefaultManager.shared.accessToken)
                
                return .concatenate([
                    .run { send in
                        await send(.channeListlResponse(networkManager.getMyChannels(request: WorkspaceIDDTO(workspace_id: workspace.id))))
                    },
                    .run { send in
                        await send(.myChanneListlResponse(networkManager.getChannels(request: WorkspaceIDDTO(workspace_id: workspace.id))))
                    }
                ])
                
                
            case let .channeListlResponse(.success(response)):
                state.channelList = utils.getSortedChannelList(from: response).filter({ channel in
                    return channel.name != "일반"
                })
                
                return .none
                
            case let .myChanneListlResponse(.success(response)):
                state.myChannelList = utils.getSortedChannelList(from: response)
                
                return .none
                
            case let .channeListlResponse(.failure(error)), let .myChanneListlResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(errorType, error, "❗️ channeListlResponse error")
                
                return .none
                
            default :
                return .none
            }
        }
    }
}

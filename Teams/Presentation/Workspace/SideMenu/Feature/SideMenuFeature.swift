//
//  SideMenuFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI


@Reducer
struct SideMenuFeature {
    @ObservableState
    struct State : Equatable {
        var workspaceCount : Int = 0
        var listScroll = true
        var workspaceList : [Workspace] = []
    }
    
    enum Action {
        case createWorkspaceTapped
        case onAppear
        case myWorkspaceResponse(Result<[Workspace], APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager

    var body : some ReducerOf<Self> {
        
        Reduce<State, Action> { state, action in
            
            switch action {
            case .onAppear:
                print("Workspace Coordinator 뿅 🌟🌟🌟🌟🌟🌟🌟🌟🌟")
                return .run { send in
                    await send(.myWorkspaceResponse(
                        networkManager.getWorkspaceList()
                    ))
                }
                
            case let .myWorkspaceResponse(.success(response)):
                
                state.workspaceCount = response.count
                
                if state.workspaceCount > 10 {
                    state.listScroll = false
                }
                
                state.workspaceList = response
                
                return .none
                
            case let .myWorkspaceResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                
                print(errorType)
                
                return .none
                
            default :
                return .none
            }
        }
    }
}

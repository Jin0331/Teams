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
        var showList : viewState = .loading
        var workspaceIdCurrent : String = ""
        var workspaceOwnerID : String = ""
        var workspaceList : [Workspace] = []
        
        enum viewState  {
            case loading
            case success
            case failed
        }
    }
    
    enum Action : BindableAction {
        case createWorkspaceTapped
        case onAppear
        case myWorkspaceResponse(Result<[Workspace], APIError>)
        case workspaceRemoveButtonTapped
        case workspaceRemove(String)
        case workspaceExitButtonTapped
        case workspaceExit(String)
        case workspaceExitManager
        case workspaceEdit(Workspace)
        case workspaceTransition(Workspace)
        case binding(BindingAction<State>)
    }
    
    @Dependency(\.networkManager) var networkManager

    var body : some ReducerOf<Self> {
        
        Reduce<State, Action> { state, action in
            
            switch action {
            case .onAppear:
                return .run { send in
                    await send(.myWorkspaceResponse(
                        networkManager.getWorkspaceList()
                    ))
                }
                
            case let .myWorkspaceResponse(.success(response)):
                
                state.workspaceCount = response.count
                
                if state.workspaceCount > 0 {
                    state.showList = .success
                } else {
                    state.showList = .failed
                }
                
                state.workspaceList = response
                
                return .none
                
            case let .myWorkspaceResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                print(error, errorType)
                return .none
                
            case .workspaceRemoveButtonTapped:
                return .send(.workspaceRemove(state.workspaceIdCurrent))
                
            case .workspaceExitButtonTapped:
                return .send(.workspaceExit(state.workspaceIdCurrent))
                
            default :
                return .none
            }
        }
    }
}

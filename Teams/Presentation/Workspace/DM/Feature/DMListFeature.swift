//
//  DMListFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMListFeature {
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
    }
    
    enum ButtonTapped {
        case inviteMemberButtonTapped
    }
    
    enum NetworkResponse {
        case workspaceMembersResponse(Result<UserList, APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
            case .onAppear:
                
                guard let currentWorkspace = state.currentWorkspace else { return .none }
                
                return .run { send in
                    await send(.networkResponse(.workspaceMembersResponse(
                        networkManager.getWorkspaceMember(request: WorkspaceIDRequestDTO(workspace_id: currentWorkspace.workspaceID, channel_id: "")))
                    ))
                }
                
            case let .networkResponse(.workspaceMembersResponse(.success(member))):
                
                dump(member)
                state.workspaceMember = member
                
                if state.workspaceMember.count < 2 {
                    state.viewType = .empty
                    return .none
                } else {
                    state.viewType = .normal
                    return .run { send in
                        
                    }
                }
                
                
            case let .networkResponse(.workspaceMembersResponse(.failure(error))):
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
}

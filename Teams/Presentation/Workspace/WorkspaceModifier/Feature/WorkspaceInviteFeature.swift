//
//  WorkspaceInviteFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct WorkspaceInviteFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentWorkspace : Workspace?
        var email : String = ""
        var emailValid : Bool = false
        var inviteButton : Bool = false
        var toastPresent : ToastMessage?
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case duplicate = "이미 워크스페이스에 소속된 팀원이에요."
            case notMember = "회원 정보를 찾을 수 없습니다."
            case emailInvalid = "올바른 이메일을 입력해주세요."
        }
    }
    
    enum Action : BindableAction {
        case binding(BindingAction<State>)
        case dismiss
        case inviteButtonTapped
        case inviteButtonActive
        case inviteResponse(Result<User, APIError>)
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var validTest
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .binding(\.email):
                return .send(.inviteButtonActive)
                
            case .inviteButtonActive:
                if !state.email.isEmpty {
                    state.inviteButton = true
                } else {
                    state.inviteButton = false
                }
                return .none
                
                
            case .inviteButtonTapped:
                state.emailValid = validTest.validEmail(state.email)
                
                if let field = [state.emailValid].firstIndex(of: false) {
                    state.toastPresent = State.ToastMessage.allCases[field]
                    return .none
                }
                
                guard let workspace = state.currentWorkspace else { return .none }
                return .run { [email = state.email ]send in
                    await send(.inviteResponse(
                        networkManager.inviteMember(request: WorkspaceIDRequestDTO(workspace_id: workspace.id), query: WorkspaceEmailRequestDTO(email: email))
                    ))
                }
            
            default :
                return .none
            }
        }
    }
}


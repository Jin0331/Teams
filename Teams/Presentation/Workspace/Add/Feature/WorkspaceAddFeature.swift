//
//  WorkspaceAddFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct WorkspaceAddFeature {
    
    @ObservableState
    struct State : Equatable {
        var workspaceName : String = ""
        var workspaceNameValid : Bool = false
        var workspaceDescription : String = ""
        var createButton : Bool = false
        var toastPresent : ToastMessage?
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case name = "워크스페이스 이름은 1~30자로 설정해주세요"
            case image = "워크스페이스 이미지를 등록해주세요."
        }
    }
    
    enum Action : BindableAction {
        case binding(BindingAction<State>)
        case createButtonActive
        case createButtonTapped
    }
    
    @Dependency(\.validTest) var validTest
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
            case .binding(\.workspaceName):
                return .send(.createButtonActive)
                                
            case .createButtonActive:
                if !state.workspaceName.isEmpty {
                    state.createButton = true
                } else {
                    state.createButton = false
                }
                return .none
            
            case .createButtonTapped:
                state.workspaceNameValid = validTest.isValidNickname(state.workspaceName)
                
                
                return .none
                
            default :
                return .none
            }
        }
    }
}

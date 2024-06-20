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
        var workspaceDescription : String = ""
        var createButton : Bool = false
    }
    
    enum Action : BindableAction {
        case binding(BindingAction<State>)
        case createButtonActive
        case createButtonTapped
    }
    
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
            
            default :
                return .none
            }
            
        }
        
    }
}

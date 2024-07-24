//
//  SearchFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import SwiftUI
import ComposableArchitecture

@Reducer
struct SearchFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentWorkspace : Workspace?
    }
    
    enum Action : BindableAction {
        case onAppear
        case binding(BindingAction<State>)
        case networkResponse(NetworkResponse)
        case buttonTapped(ButtonTapped)
    }
    
    enum ButtonTapped {
        
    }
    
    enum NetworkResponse {
        
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        BindingReducer()
        
        Reduce<State, Action> { state, action in
            switch action {
                
                
            default :
                return .none
            }
        }
    }
}

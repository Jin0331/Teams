//
//  SignUpFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/4/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SignUpFeature {
    
    @ObservableState
    struct State: Equatable {
        var email = ""
    }
    
    enum Action {
        case emailChanged(String)
    }
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
        
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none
            }
                
        }
    }
    
}

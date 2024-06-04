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
        case dismiss
        case emailChanged(String)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
        
            switch action {
            case let .emailChanged(email):
                state.email = email
                return .none
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
            }
                
        }
    }
    
}

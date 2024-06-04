//
//  AuthFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct AuthFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp : SignUpFeature.State?
    }
    
    enum Action {
        case signUp(PresentationAction<SignUpFeature.Action>)
        case signUpButtonTapped
        case signUpPresentation
    }
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .signUp:
                return .none
            case .signUpButtonTapped:
                return .run { send in
                    await send(.signUpPresentation)
                }
            case .signUpPresentation:
                state.signUp = SignUpFeature.State()
                return .none
            }
        }
        .ifLet(\.$signUp, action: \.signUp) {
            SignUpFeature()
        }
        
    }
    
}

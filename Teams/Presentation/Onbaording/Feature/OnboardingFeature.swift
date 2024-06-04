//
//  OnboardingFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct OnboardingFeature {
    
    @ObservableState
    struct State {
        @Presents var login: AuthFeature.State?
    }
    
    enum Action {
        case login(PresentationAction<AuthFeature.Action>)
        case loginButtonTapped
        case loginPresentation
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .login:
                return .none
                
            case .loginButtonTapped:
                return .run { send in
                    await send(.loginPresentation)
                }
                
            case .loginPresentation:
                state.login = AuthFeature.State()
                return .none
                
            }
        }
        .ifLet(\.$login, action: \.login) {
            AuthFeature()
        }
    }
}

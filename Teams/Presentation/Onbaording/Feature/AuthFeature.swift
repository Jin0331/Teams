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
        @Presents var emailLogin : EmailLoginFeature.State?
    }
    
    enum Action {
        case signUp(PresentationAction<SignUpFeature.Action>)
        case emailLogin(PresentationAction<EmailLoginFeature.Action>)
        case signUpButtonTapped
        case signUpPresentation
        case emailLoginButtonTapped
        case emailLoginPresentation
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case let .signUp(childAction):
                switch childAction {
                case .dismiss:
                    return .run { send in
                        await self.dismiss()
                    }
                default:
                    return .none
                }
                
            case let .emailLogin(childAction):
                switch childAction {
                case .dismiss:
                    return .run { send in
                        await self.dismiss()
                    }
                default:
                    return .none
                }
                
            case .signUpButtonTapped:
                return .run { send in
                    await send(.signUpPresentation)
                }
            case .signUpPresentation:
                state.signUp = SignUpFeature.State()
                return .none
            
            case .emailLoginButtonTapped:
                return .run { send in
                    await send(.emailLoginPresentation)
                }
            
            case .emailLoginPresentation:
                state.emailLogin = EmailLoginFeature.State()
                return .none
            }
        }
        .ifLet(\.$signUp, action: \.signUp) {
            SignUpFeature()
        }
        .ifLet(\.$emailLogin, action: \.emailLogin) {
            EmailLoginFeature()
        }
        
    }
    
}

//
//  SignUpFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/4/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct SignUpFeature {
    
    @ObservableState
    struct State: Equatable {
        var emailText = ""
        var nicknameText = ""
        var phoneNumberText = ""
        var passwordText = ""
        var passwordRepeatText = ""
        var emailValid = false
    }
    
    enum Action {
        case dismiss
        
        // text Change
        case emailChanged(String)
        case nicknameChanged(String)
        case phoneNumberChanged(String)
        case passwordChanged(String)
        case passwordRepeatChanged(String)
        
        // valid
        case isEmailValid(String)
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
        
            switch action {
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
                
            case let .emailChanged(email):
                state.emailText = email
                return .run { [email = state.emailText] send in
                    await send(.isEmailValid(email))
                }
            case let .nicknameChanged(nickname):
                state.nicknameText = nickname
                return .none
            case let .phoneNumberChanged(phoneNumber):
                state.phoneNumberText = phoneNumber
                return .none
            case let .passwordChanged(password):
                state.passwordText = password
                return .none
            case let .passwordRepeatChanged(passwordRepeat):
                state.passwordRepeatText = passwordRepeat
                return .none
                
                
            case let .isEmailValid(email):
                
                state.emailValid = validEmail(email) ? true : false
                
                return .none
            }
                
        }
    }
    
}

//MARK: - 유효성 검증 함수
extension SignUpFeature {
    private func validEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        
        return emailPredicate.evaluate(with: email)
    }
}

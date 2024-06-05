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
        var nicknameValid = false
        var phoneNumberValid = false
        var passwordValid = false
        var passwordRepeatValid = false
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
        case isNicknameValid(String)
        case isPhoneNumberValid(String)
        case isPasswordValid(String)
        case isPasswordRepeatValid(String, String)
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
                return .run { [nickname = state.nicknameText] send in
                    await send(.isNicknameValid(nickname))
                }
                
            case let .phoneNumberChanged(phoneNumber):
                state.phoneNumberText = phoneNumber
                return .run { [phoneNumber = state.phoneNumberText] send in
                    await send(.isPhoneNumberValid(phoneNumber))
                }
                
            case let .passwordChanged(password):
                state.passwordText = password
                return .run { [password = state.passwordText] send in
                    await send(.isPasswordValid(password))
                }
                
            case let .passwordRepeatChanged(passwordRepeat):
                state.passwordRepeatText = passwordRepeat
                return .run { [password = state.passwordText,
                               passwordRepeat = state.passwordRepeatText] send in
                    await send(.isPasswordRepeatValid(password, passwordRepeat))
                }
                
            case let .isEmailValid(email):
                state.emailValid = validEmail(email)
                return .none
                
            case let .isNicknameValid(nickname):
                state.nicknameValid = isValidNickname(nickname)
                return .none
                
            case let .isPhoneNumberValid(phoneNumber):
                state.phoneNumberValid = isValidPhoneNumber(phoneNumber)
                let clean = phoneNumber.filter { $0.isNumber }
                state.phoneNumberText = formatPhoneNumber(clean)
                return .none
                
            case let .isPasswordValid(password):
                state.passwordValid = isValidPassword(password)
                return .none
                
            case let .isPasswordRepeatValid(password, passwordRepeat):
                state.passwordRepeatValid = password == passwordRepeat ? true : false
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
    
    private func isValidNickname(_ nickname: String) -> Bool {
        let minCharacters = 1
        let maxCharacters = 30
        
        return nickname.count >= minCharacters && nickname.count <= maxCharacters
    }
    
    private func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneRegex = "^01\\d{1}-\\d{3,4}-\\d{4}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        
        return phonePredicate.evaluate(with: phoneNumber)
    }
    
    private func formatPhoneNumber(_ number: String) -> String {
        var result = ""
        let mask = number.count < 11 ? "XXX-XXX-XXXX" : "XXX-XXXX-XXXX"
        var index = number.startIndex
        for change in mask where index < number.endIndex {
            if change == "X" {
                result.append(number[index])
                index = number.index(after: index)
            } else {
                result.append(change)
            }
        }
        return result
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        // 최소 8자 이상, 대소문자, 숫자, 특수문자를 포함하는 정규표현식
        let passwordRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        
        return passwordPredicate.evaluate(with: password)
    }

}

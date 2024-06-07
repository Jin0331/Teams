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
        
        var emailDuplicate : Bool = false
        var emailValid : Bool?
        var nicknameValid : Bool?
        var phoneNumberValid : Bool?
        var passwordValid : Bool?
        var passwordRepeatValid : Bool?
        
        var completeButton : Bool = false
        var focusedField: Field?
        
        enum Field: String, Hashable, CaseIterable {
            case email, nickname, phoneNumber, password, passwordRepeat
        }
    }
    
    enum Action : BindableAction {
        case dismiss
        case binding(BindingAction<State>)
        case phoneNumberChange(String)
        case completeButtonActive
        case completeButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    
    var body : some Reducer<State, Action> {
        BindingReducer()
        
        Reduce { state, action in
            
            switch action {
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
                
            case .binding(\.emailText):
                state.emailDuplicate = !state.emailText.isEmpty ? true : false
                return .send(.completeButtonActive)
                
            //MARK: - iOS 17 TextField Bug 대응. 하위 버전에서도 문제없이 작동
            case .binding(\.phoneNumberText):
                return .run { [phoneNumber = state.phoneNumberText] send in
                    await send(.phoneNumberChange(phoneNumber))
                }
                
            case let .phoneNumberChange(phoneNumber):
                let clean = phoneNumber.filter { $0.isNumber }
                state.phoneNumberText = formatPhoneNumber(clean)
                return .send(.completeButtonActive)
            
            case .binding(\.nicknameText), .binding(\.passwordText), .binding(\.passwordRepeatText):
                return .send(.completeButtonActive)
            
            case .completeButtonActive:
                if !state.emailText.isEmpty && !state.nicknameText.isEmpty && !state.passwordText.isEmpty && !state.passwordRepeatText.isEmpty {
                    state.completeButton = true
                } else {
                    state.completeButton = false
                }
                return .none
                
            case .completeButtonTapped:
                state.emailValid = validEmail(state.emailText)
                state.nicknameValid = isValidNickname(state.nicknameText)
                state.phoneNumberValid = isValidPhoneNumber(state.phoneNumberText)
                state.passwordValid = isValidPassword(state.passwordText)
                state.passwordRepeatValid = isPasswordMatch(state.passwordText, state.passwordRepeatText)
                
                // focuseState
                if let field = [state.emailValid, state.nicknameValid, state.phoneNumberValid, state.passwordValid].enumerated().first(where: { $0.element == false }) {
                    state.focusedField = SignUpFeature.State.Field.allCases[field.offset]
                } else {
                    state.focusedField = .passwordRepeat
                }
                
                return .none
                
            default :
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
    
    private func isPasswordMatch(_ password: String, _ passwordRepeat: String) -> Bool {
        return password == passwordRepeat
    }
}

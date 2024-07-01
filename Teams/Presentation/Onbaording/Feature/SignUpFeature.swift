//
//  SignUpFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/4/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct SignUpFeature {
    
    @ObservableState
    struct State : Equatable{
        let id = UUID()
        var emailText = ""
        var nicknameText = ""
        var phoneNumberText = ""
        var passwordText = ""
        var passwordRepeatText = ""
                
        var emailDuplicate : Bool = false
        var emailDuplicateButton : Bool = false
        var emailValid : Bool?
        var nicknameValid : Bool?
        var phoneNumberValid : Bool?
        var passwordValid : Bool?
        var passwordRepeatValid : Bool?
        
        var completeButton : Bool = false
        var focusedField: Field?
        var toastPresent : ToastMessage?
        
        var inputView = InputFeature.State()
        
        enum Field: String, Hashable, CaseIterable {
            case email, nickname, phoneNumber, password, passwordRepeat, emailDuplicate
        }
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case email = "이메일 중복 확인을 진행해주세요."
            case nickname = "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
            case phoneNumber = "잘못된 전화번호 형식입니다."
            case password = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 설정해주세요."
            case passwordRepeat = "작성하신 비밀번호가 일치하지 않습니다."
            case emailDuplicate = "이미 등록된 이메일입니다."
            case emailFormat = "이메일 형식이 올바르지 않습니다."
            case emailValid = "사용 가능한 이메일입니다."
            case none = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
    
    enum Action : BindableAction {
        case dismiss
        case binding(BindingAction<State>)
        case phoneNumberChange(String)
        case completeButtonActive
        case completeButtonTapped
        case signUpComplete(String)
        case emailValidationResponse(Result<EmailVaidationResponseDTO, APIError>)
        case joinResponse(Result<Join, APIError>)
        case inputView(InputFeature.Action)
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var validTest
    
    var body : some Reducer<State, Action> {
        Scope(state: \.inputView, action: /Action.inputView) {
            InputFeature()
        }
        
        BindingReducer()
        
        Reduce { state, action in
            
            switch action {                
            case .binding(\.emailText):
                state.emailDuplicateButton = !state.emailText.isEmpty ? true : false
                return .send(.completeButtonActive)
                
            //MARK: - iOS 17 TextField Bug 대응. 하위 버전에서도 문제없이 작동
            case .binding(\.phoneNumberText):
                return .run { [phoneNumber = state.phoneNumberText] send in
                    await send(.phoneNumberChange(phoneNumber))
                }
                
            case let .phoneNumberChange(phoneNumber):
                let clean = phoneNumber.filter { $0.isNumber }
                state.phoneNumberText = validTest.formatPhoneNumber(clean)
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
                state.emailValid = validTest.validEmail(state.emailText)
                state.nicknameValid = validTest.isValidNickname(state.nicknameText)
                state.phoneNumberValid = validTest.isValidPhoneNumber(state.phoneNumberText)
                state.passwordValid = validTest.isValidPassword(state.passwordText)
                state.passwordRepeatValid = validTest.isPasswordMatch(state.passwordText, state.passwordRepeatText)
                
                // 유효성 검증
                if let field = [state.emailValid, state.nicknameValid, state.phoneNumberValid, state.passwordValid, state.passwordRepeatValid].firstIndex(of: false) {
                    state.toastPresent = State.ToastMessage.allCases[field]
                    state.focusedField = State.Field.allCases[field]
                    
                    return .none
                }
                
                if !state.emailDuplicate {
                    state.toastPresent = State.ToastMessage.email
                
                    return .none
                }

                let joinRequest = JoinRequestDTO(email: state.emailText,
                                                 password: state.passwordText,
                                                 nickname: state.nicknameText,
                                                 phone: state.phoneNumberText,
                                                 deviceToken: UserDefaultManager.shared.deviceToken!)
                
                return .run { send in
                    await send(.joinResponse(
                        networkManager.join(query:joinRequest)
                    ))
                }
            
            case let .inputView(inputView):
                
                switch inputView {
                    
                case .emailValidationButtonTapped:
                    
                    return .run { [email = state.emailText] send in
                        await send(.emailValidationResponse(
                            networkManager.emailValidation(query: EmailVaidationRequestDTO(email: email))
                        ))
                    }
                }
            
            case .emailValidationResponse(.success) :
                
                state.toastPresent = State.ToastMessage.emailValid
                state.emailDuplicate = true
                
                return .none
                
            case let .emailValidationResponse(.failure(error)) :
                
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                state.emailDuplicate = false
                
                print(error)
                
                if case .E11 = errorType {
                    state.toastPresent = State.ToastMessage.emailFormat
                } else if case .E12 = errorType {
                    state.toastPresent = State.ToastMessage.emailDuplicate
                } else {
                    state.toastPresent = State.ToastMessage.none
                }
                
                return .none
            
            case let .joinResponse(.success(response)):
                
                UserDefaultManager.shared.saveAllData(login: response)
                
                return .send(.signUpComplete(response.nickname))
                
            case let .joinResponse(.failure(error)):
                
                print(error)
                state.toastPresent = State.ToastMessage.none
                
                return .none

            default :
                return .none
            }
        }
    }
}

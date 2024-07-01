//
//  EmailLoginFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct EmailLoginFeature {
    
    @ObservableState
    struct State : Equatable{
        let id = UUID()
        var emailText = ""
        var passwordText = ""
        var emailValid : Bool?
        var passwordValid : Bool?
        
        var focusedField: Field?
        var toastPresent : ToastMessage?
        var completeButton : Bool = false
        
        enum Field: String, Hashable, CaseIterable {
            case email, password
        }
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case email = "이메일 형식이 올바르지 않습니다."
            case password = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 입력해주세요."
            case loginFailure = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
            case none = "알 수 없는 에러"
        }
    }
    
    enum Action : BindableAction {
        case dismiss
        case binding(BindingAction<State>)
        case loginButtonActive
        case loginButtonTapped
        case emailLoginResponse(Result<Join, APIError>)
        case myWorkspaceResponse(Result<[Workspace], APIError>)
        case loginComplete([Workspace])
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var validTest
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
                
            switch action {
                
            case .binding(\.emailText), .binding(\.passwordText):
                return .send(.loginButtonActive)
            
            case .loginButtonActive:
                if !state.emailText.isEmpty && !state.passwordText.isEmpty {
                    state.completeButton = true
                } else {
                    state.completeButton = false
                }
                return .none
            
                
            case .loginButtonTapped:
                state.emailValid = validTest.validEmail(state.emailText)
                state.passwordValid = validTest.isValidPassword(state.passwordText)
                
                if let field = [state.emailValid, state.passwordValid].firstIndex(of: false) {
                    state.toastPresent = State.ToastMessage.allCases[field]
                    state.focusedField = State.Field.allCases[field]
                    
                    return .none
                }
                
                let emailLoginRequest = EmailLoginRequestDTO(email: state.emailText,
                                                             password: state.passwordText,
                                                             deviceToken: UserDefaultManager.shared.deviceToken!)
                
                
                return .run { send in
                    await send(.emailLoginResponse(
                        networkManager.emailLogin(query: emailLoginRequest)
                    ))
                }
            
            case let .emailLoginResponse(.success(response)):
                
                UserDefaultManager.shared.saveAllData(login: response)
                
                //TODO: - Workspace 조ㅓ회
                return .run { send in
                    await send(.myWorkspaceResponse(
                        networkManager.getWorkspaceList()
                    ))
                }
            
            case let .myWorkspaceResponse(.success(response)):
                print(response, "🌟 success")
                return .send(.loginComplete(response))
                
            case let .myWorkspaceResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                
                print(errorType)
                
                return .none
                
            case let .emailLoginResponse(.failure(error)):
                
                let errorType = APIError.networkErrorType(error: error.errorDescription)                
                if case .E03 = errorType {
                    state.toastPresent = State.ToastMessage.loginFailure
                } else {
                    state.toastPresent = State.ToastMessage.none
                }
                
                return .none
                
            default :
                return .none
            }
            
        }
    }
}

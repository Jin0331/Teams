//
//  AuthFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import AuthenticationServices
import KakaoSDKCommon
import KakaoSDKAuth
import KakaoSDKUser
import SwiftUI

@Reducer
struct AuthFeature {
    
    @ObservableState
    struct State: Equatable {
        @Presents var signUp : SignUpFeature.State?
        @Presents var emailLogin : EmailLoginFeature.State?
        var toastPresent : ToastMessage?
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case email = "이메일 형식이 올바르지 않습니다."
            case password = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 입력해주세요."
            case loginFailure = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
            case none = "알 수 없는 에러"
        }
    }
    
    enum Action {
        case signUp(PresentationAction<SignUpFeature.Action>)
        case emailLogin(PresentationAction<EmailLoginFeature.Action>)
        case signUpButtonTapped
        case signUpPresentation
        case appleLoginRequest(ASAuthorizationAppleIDRequest)
        case appleLoginCompletion(ASAuthorizationAppleIDCredential)
        case kakaoLoginButtonTapped
        case kakaoLoginUsingApp(Result<OAuthToken, Error>)
        case kakaoLoginUsingWeb(Result<OAuthToken, Error>)
        case emailLoginButtonTapped
        case emailLoginPresentation
        case loginResponse(Result<Join, APIError>)
        case loginFailure
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.networkManager) var networkManager
    
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
                
            case let .appleLoginRequest(request):
                request.requestedScopes = [.fullName, .email]
                return .none
                
            case let .appleLoginCompletion(appleIDCredential):
                if let identityToken = appleIDCredential.identityToken, let identifyTokenString = String(data: identityToken, encoding: .utf8) {
                    let fullName = appleIDCredential.fullName
                    let name =  (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
                    let request = AppleLoginRequestDTO(idToken: identifyTokenString,
                                                       nickname: name,
                                                       deviceToken: UserDefaultManager.shared.deviceToken!)
                    return .run { send in
                        await send(.loginResponse(
                            networkManager.appleLogin(query: request)
                        ))
                    }
                }
                return .none
                
            case .kakaoLoginButtonTapped:
                if UserApi.isKakaoTalkLoginAvailable() {
                    return .run { send in
                        await send(.kakaoLoginUsingApp(networkManager.kakaoLoginWithKakaoTalkCallBack()))
                    }
                } else {
                    return .run { send in
                        await send(.kakaoLoginUsingWeb(networkManager.kakaoLoginWithKakaoAccountCallBack()))
                    }
                }
            case let .kakaoLoginUsingApp(.success(oauthToken)):
                print(oauthToken, "🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟")
                return .none
                
            case .kakaoLoginUsingApp(.failure):
                state.toastPresent = State.ToastMessage.loginFailure
                return .none
                
                
            case let .kakaoLoginUsingWeb(.success(oauthToken)):
                print(oauthToken, "🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟🌟")
                return .none
                
            case .kakaoLoginUsingWeb(.failure):
                state.toastPresent = State.ToastMessage.loginFailure
                return .none
                
            case .emailLoginButtonTapped:
                return .run { send in
                    await send(.emailLoginPresentation)
                }
                
            case .emailLoginPresentation:
                state.emailLogin = EmailLoginFeature.State()
                return .none
                
            case let .loginResponse(.success(response)):
                
                UserDefaultManager.shared.saveAllData(login: response)
                return .none
                
            case let .loginResponse(.failure(error)):
                let errorType = APIError.networkErrorType(error: error.errorDescription)
                if case .E03 = errorType {
                    state.toastPresent = State.ToastMessage.loginFailure
                } else {
                    state.toastPresent = State.ToastMessage.none
                }
                
                return .none
                
            case .loginFailure:
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

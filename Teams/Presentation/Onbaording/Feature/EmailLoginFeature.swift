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
    struct State : Equatable {
        var emailText = ""
        var passwordText = ""
        var emailValid : Bool?
        var passwordValid : Bool?
        
        var focusedField: Field?
        var completeButton : Bool = false
        
        enum Field: String, Hashable, CaseIterable {
            case email, password
        }
        
        enum ToastMessage : String, Hashable, CaseIterable {
            case email = "이메일 형식이 올바르지 않습니다."
            case password = "비밀번호는 최소 8자 이상, 하나 이상의 대소문자/숫자/특수 문자를 입력해주세요."
            case none = "에러가 발생했어요. 잠시 후 다시 시도해주세요."
        }
    }
    
    enum Action : BindableAction {
        case dismiss
        case binding(BindingAction<State>)
        case loginButtonActive
        case loginButtonTapped
    }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
                
            switch action {
                
            case .dismiss:
                return .run { send in
                    await self.dismiss()
                }
                
            case .binding(\.emailText), .binding(\.passwordText):
                return .send(.loginButtonActive)
            
            case .loginButtonActive:
                if !state.emailText.isEmpty && !state.passwordText.isEmpty {
                    state.completeButton = true
                } else {
                    state.completeButton = false
                }
                return .none
            
            default :
                return .none
            }
            
        }
    }
}

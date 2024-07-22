//
//  ProfileEditFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/23/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileEditFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentProfile : Profile
        var viewType : viewState
        var nickname : String = ""
        var nicknameValid : Bool = false
        var phonenumber : String = ""
        var phonenumberValid : Bool = false
        var editButton : Bool = false
        var toastPresent : ToastMessage?
    }
    
    enum Action : BindableAction {
        case onAppear
        case goBack
        case phoneNumberChange(String)
        case buttonTapped(ButtonTapped)
        case binding(BindingAction<State>)
    }
    
    enum ButtonTapped {
        case editButtonActive
        case editNicknameButtonTapped
        case editPhonenumberButtonTapped
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utilitiesFunction
    
    var body : some Reducer<State, Action> {
        
        BindingReducer()
        
        Reduce { state, action in
            switch action {
                
            case .binding(\.nickname):
                return .send(.buttonTapped(.editButtonActive))
                
            case .binding(\.phonenumber):
                return .run { [phoneNumber = state.phonenumber] send in
                    await send(.phoneNumberChange(phoneNumber))
                }
                
            case let .phoneNumberChange(phoneNumber):
                let clean = phoneNumber.filter { $0.isNumber }
                state.phonenumber = utilitiesFunction.formatPhoneNumber(clean)
                return .send(.buttonTapped(.editButtonActive))
                
            case .buttonTapped(.editButtonActive):
                if !state.nickname.isEmpty || !state.phonenumber.isEmpty {
                    state.editButton = true
                } else {
                    state.editButton = false
                }
                
                return .none
                
            case .buttonTapped(.editNicknameButtonTapped):
                
                if utilitiesFunction.isValidNickname(state.nickname) {
                    print(state.nickname)
                    return .run { send in
                        
                    }
                } else {
                    state.toastPresent = .nickname
                    return .none
                }
                
            case .buttonTapped(.editPhonenumberButtonTapped):
                
                if utilitiesFunction.isValidPhoneNumber(state.phonenumber) {
                    print(state.phonenumber)
                    return .run { send in
                        
                    }
                } else {
                    state.toastPresent = .phoneNumber
                    return .none
                }
            default :
                return .none
            }
        }
    }
}

extension ProfileEditFeature {
    enum viewState  {
        case nickname
        case phonenumber
    }
    
    enum ToastMessage : String, Hashable, CaseIterable {
        case nickname = "닉네임은 1글자 이상 30글자 이내로 부탁드려요."
        case phoneNumber = "잘못된 전화번호 형식입니다."
    }
}

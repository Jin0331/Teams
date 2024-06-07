//
//  SignUpView.swift
//  Teams
//
//  Created by JinwooLee on 6/4/24.
//

import ComposableArchitecture
import SwiftUI

struct SignUpView: View {
    
    @State var store : StoreOf<SignUpFeature>
    @FocusState var focusedField: SignUpFeature.State.Field?
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing : 20) {
                    UserInputView(title: "이메일", placement: "이메일을 입력하세요", text: $store.emailText, valid: store.emailValid, isEmail: true, emailValid : store.emailDuplicate, focusState: $focusedField)
                    
                    UserInputView(title: "닉네임", placement: "닉네임을 입력하세요", text: $store.nicknameText, valid: store.nicknameValid, focusState: $focusedField)
                    
                    UserInputView(title: "연락처", placement: "연락처를 입력하세요", text: $store.phoneNumberText, valid: store.phoneNumberValid, isNumber: true, focusState: $focusedField)
                    
                    UserInputView(title: "비밀번호", placement: "비밀번호를 입력하세요", text: $store.passwordText, valid: store.passwordValid, isPassword: true, focusState: $focusedField)
                    
                    UserInputView(title: "비밀번호 확인", placement: "비밀번호를 한 번 더 입력하세요", text: $store.passwordRepeatText, valid: store.passwordRepeatValid, isPasswordRepeat: true, focusState: $focusedField)
                    
                    Spacer()
                    
                    Button("가입하기") {
                        store.send(.completeButtonTapped)
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.completeButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.completeButton)
                }
                .padding()
                .bind($store.focusedField, to: $focusedField)
                .navigationBarTitle("회원가입", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {
                            store.send(.dismiss)
                        } label : {
                            Image("Vector")
                        }
                )
            }
        }
    }
}

#Preview {
    SignUpView(store: Store(initialState: SignUpFeature.State(), reducer: {
        SignUpFeature()
    }))
}

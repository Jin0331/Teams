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
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing : 20) {
                    UserInputView(title: "이메일", placement: "이메일을 입력하세요", store: $store.emailText, isEmail: true, emailValid : store.emailValid)
                    
                    UserInputView(title: "닉네임", placement: "닉네임을 입력하세요", store: $store.nicknameText)
                    
                    UserInputView(title: "연락처", placement: "연락처를 입력하세요", store: $store.phoneNumberText, isNumber: true)
                    
                    UserInputView(title: "비밀번호", placement: "비밀번호를 입력하세요", store: $store.passwordText, isPassword: true)
                    
                    UserInputView(title: "비밀번호 확인", placement: "비밀번호를 한 번 더 입력하세요", store: $store.passwordRepeatText, isPassword: true)
                    
                    
                    Spacer()
                    
                    Button("가입하기") {
                        print("hihi")
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.completeButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.completeButton)
                }
                .padding()
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

//
//  SignUpView.swift
//  Teams
//
//  Created by JinwooLee on 6/4/24.
//

import ComposableArchitecture
import SwiftUI

struct SignUpView: View {
    
    @Perception.Bindable var store : StoreOf<SignUpFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing : 20) {
                    UserInputView(title: "이메일", placement: "이메일을 입력하세요", store: $store.emailText.sending(\.emailChanged), isEmail: true, emailValid : store.emailValid)
                    
                    UserInputView(title: "닉네임", placement: "닉네임을 입력하세요", store: $store.nicknameText.sending(\.nicknameChanged))
                    
                    UserInputView(title: "연락처", placement: "연락처를 입력하세요", store: $store.phoneNumberText.sending(\.phoneNumberChanged))
                    
                    UserInputView(title: "비밀번호", placement: "비밀번호를 입력하세요", store: $store.passwordText.sending(\.passwordChanged), isPassword: true)
                    
                    UserInputView(title: "비밀번호 확인", placement: "비밀번호를 한 번 더 입력하세요", store: $store.passwordRepeatText.sending(\.passwordRepeatChanged), isPassword: true)
                    
                    Spacer()
                    
                    Button("가입하기") {
                        
                    }
                    .tint(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(.brandInActive)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
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


struct UserInputView: View {
    
    var title : String
    var placement : String
    var store : Binding<String>
    var isEmail : Bool = false
    var isPassword : Bool = false
    var emailValid : Bool = false
    
    var body: some View {
        VStack(alignment : .leading, spacing: 10) {
            Text(title)
                .title2()
            HStack(spacing : 5) {
                
                if isEmail {
                    TextField(placement, text: store)
                        .bodyRegular()
                        .padding()
                        .frame(width: 233, height: 44)
                    
                    Button("중복 확인") {
                        
                    }
                    .frame(width: 100, height: 44)
                    .title2()
                    .foregroundStyle(.brandWhite)
                    .background(backgroundForIsActive(emailValid))
                    .cornerRadius(8)
                } else {
                    
                    if isPassword {
                        SecureField(placement, text: store)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44)
                    } else {
                        TextField(placement, text: store)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44)
                    }
                    

                }
            }
        }
        .frame(width: 345, height: 76)
    }
}


#Preview {
    SignUpView(store: Store(initialState: SignUpFeature.State(), reducer: {
        SignUpFeature()
    }))
}

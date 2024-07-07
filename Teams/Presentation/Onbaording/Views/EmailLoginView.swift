//
//  EmailLoginView.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import ComposableArchitecture
import SwiftUI
import PopupView

struct EmailLoginView : View {
    
    @State var store : StoreOf<EmailLoginFeature>
    @FocusState var focusedField: EmailLoginFeature.State.Field?
    
    var body: some View {
        
        WithPerceptionTracking {
            NavigationStack {
                Divider().background(.brandWhite).padding(.top, 10)
                VStack(spacing: 20) {
                    
                    LoginView(title: "이메일", placement: "이메일을 입력하세요", text: $store.emailText, valid: store.emailValid)
                        .focused($focusedField, equals: .email)
                    
                    LoginView(title: "비밀번호", placement: "비밀번호를 입력하세요", text: $store.passwordText, valid: store.passwordValid, isPassword: true)
                        .focused($focusedField, equals: .password)
                    
                    
                    Button("로그인") {
                        store.send(.loginButtonTapped)
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.completeButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.completeButton)
                    
                    Spacer()
                    
                }
                .padding()
                .bind($store.focusedField, to: $focusedField)
                .popup(item: $store.toastPresent) { text in
                    ToastView(text: text.rawValue)
                } customize: {
                    $0.autohideIn(2)
                }
                .navigationBarTitle("이메일 로그인", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {
                            store.send(.dismiss)
                        } label : {
                            Image("Vector")
                        }
                )
                .navigationBarColor(backgroundColor: .brandWhite, titleColor: .brandBlack)
                .navigationViewStyle(StackNavigationViewStyle())
            }
        }
    }
}

//
//  AuthView.swift
//  Teams
//
//  Created by JinwooLee on 6/3/24.
//

import ComposableArchitecture
import AuthenticationServices
import PopupView
import SwiftUI

// 코드 리팩토링은 추후. 기능 동작 확인부터 시작

struct AuthView: View {
    
    @State var store : StoreOf<AuthFeature>
    
    var body: some View {
        WithPerceptionTracking {
            
            VStack(spacing : 20) {
                
                HStack(spacing: 10) {
                    Image(.apple)
                    Text("Apple로 계속하기")
                        .foregroundStyle(.brandWhite)
                        .title2()
                }
                .frame(width: 323, height: 44)
                .background(.appleLogin)
                .cornerRadius(6)
                .overlay {
                    SignInWithAppleButton { request in
                        store.send(.appleLoginRequest(request))
                    } onCompletion: { result in
                        if case let .success(authResult) = result {
                            store.send(.appleLoginCompletion(authResult.credential as! ASAuthorizationAppleIDCredential))
                        }
                    }
                    .blendMode(.overlay)

                }
                
                Button(action: {
                    store.send(.kakaoLoginButtonTapped)
                }, label: {
                    HStack {
                        Image(.kakao)
                        Text("카카오톡으로 계속하기")
                    }
                })
                .tint(.brandBlack)
                .frame(width: 323, height: 44)
                .title2()
                .background(.kakaoLogin)
                .cornerRadius(6)
                
                
                Button(action: {
                    store.send(.emailLoginButtonTapped)
                }, label: {
                    HStack {
                        Image(.email)
                        Text("이메일로 시작하기")
                    }
                })
                .tint(.brandWhite)
                .frame(width: 323, height: 44)
                .title2()
                .background(.brandGreen)
                .cornerRadius(6)
                .tint(.brandGreen)
                .sheet(item: $store.scope(state: \.emailLogin, action: \.emailLogin)) { store in
                    EmailLoginView(store: store)
                        .presentationDragIndicator(.visible)
                }
                
                HStack {
                    Text("또는")
                    Button("새롭게 회원가입 하기") {
                        store.send(.signUpButtonTapped)
                    }
                    .tint(.brandGreen)
                    .sheet(item: $store.scope(state: \.signUp, action: \.signUp)) { store in
                        SignUpView(store: store)
                            .presentationDragIndicator(.visible)
                    }
                }
                .title2()
            }
            .padding()
            .safeAreaInset(edge: .top, alignment: .center, spacing: nil) {
                Text("")
                    .frame(maxWidth: .infinity)
            }
            .popup(item: $store.toastPresent) { text in
                ToastView(text: text.rawValue)
            } customize: {
                $0.autohideIn(2)
            }
            
            Spacer()
        }
    }
    
}

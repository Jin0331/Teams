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
        NavigationStack {
            VStack(spacing: 20) {
                
                LoginView(title: "이메일", placement: "이메일을 입력하세요", text: $store.emailText)
                
                LoginView(title: "비밀번호", placement: "비밀번호를 입력하세요", text: $store.passwordText)
                
                Spacer()
                
                Button("로그인") {
                    store.send(.loginButtonTapped)
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


#Preview {
    EmailLoginView(store: Store(initialState: EmailLoginFeature.State(), reducer: {
        EmailLoginFeature()
    }))
}

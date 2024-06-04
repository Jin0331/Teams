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
        
        NavigationStack {
            VStack {
                VStack {
                    Text("이메일")
                        .title2()
                    TextField("이메일을 입력하세요", text: $store.email.sending(\.emailChanged))
                }
            }
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

#Preview {
    SignUpView(store: Store(initialState: SignUpFeature.State(), reducer: {
        SignUpFeature()
    }))
}

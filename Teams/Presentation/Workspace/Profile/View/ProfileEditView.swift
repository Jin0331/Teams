//
//  ProfileEditView.swift
//  Teams
//
//  Created by JinwooLee on 7/23/24.
//

import SwiftUI
import ComposableArchitecture
import PopupView

struct ProfileEditView: View {
    
    @Perception.Bindable var store : StoreOf<ProfileEditFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                Divider().background(.brandWhite)
                    .padding(.bottom, 15)
                
                VStack {
                    switch store.viewType {
                    case .nickname :
                        TextField("닉네임을 입력하세요", text : $store.nickname)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44, alignment: .leading)
                    case .phonenumber:
                        TextField("전화번호를 입력하세요", text : $store.phonenumber)
                            .bodyRegular()
                            .padding()
                            .frame(width: 345, height: 44, alignment: .leading)
                    }
                    
                    Button("완료") {
                        switch store.viewType {
                        case .nickname :
                            store.send(.buttonTapped(.editNicknameButtonTapped))
                        case .phonenumber:
                            store.send(.buttonTapped(.editPhonenumberButtonTapped))
                        }
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.editButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.editButton)
                    
                    Spacer()
                }
            }
            .popup(item: $store.toastPresent) { text in
                ToastView(text: text.rawValue)
            } customize: {
                $0.autohideIn(2)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle(store.viewType == .nickname ? "닉네임 수정" : "전화번호 수정", displayMode: .inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.goBack)
                    }, label: {
                        Image(.chevron)
                            .resizable()
                            .frame(width: 14, height: 19)
                    })
                }
            }
        }
    }
}

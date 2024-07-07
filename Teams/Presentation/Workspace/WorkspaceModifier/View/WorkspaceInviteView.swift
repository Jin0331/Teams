//
//  WorkspaceInviteView.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import ComposableArchitecture
import SwiftUI
import PopupView

struct WorkspaceInviteView: View {
    
    @State var store : StoreOf<WorkspaceInviteFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                Divider().background(.brandWhite)
                VStack(spacing: 20) {
                    Text("이메일")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .frame(width: 345, height: 24, alignment: .leading)
                        .padding(.top, 10)
                    
                    TextField("초대하려는 팀원의 이메일을 입력하세요.", text: $store.email)
                        .bodyRegular()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Button("초대 보내기") {
                        store.send(.inviteButtonTapped)
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.inviteButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.inviteButton)
                    
                    Spacer()
                    
                }
                .popup(item: $store.toastPresent) { text in
                    ToastView(text: text.rawValue)
                } customize: {
                    $0.autohideIn(2)
                }
                .navigationBarTitle("팀원 초대", displayMode: .inline)
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

#Preview {
    WorkspaceInviteView(store: Store(initialState: WorkspaceInviteFeature.State(), reducer: {
        WorkspaceInviteFeature()
    }))
}

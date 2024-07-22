//
//  ProfileEditView.swift
//  Teams
//
//  Created by JinwooLee on 7/23/24.
//

import SwiftUI
import ComposableArchitecture

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
                        Text("nickanme")
                    case .phonenumber:
                        Text("Phonenumber")
                    }
                }
            }
            .onAppear {
                
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

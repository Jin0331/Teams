//
//  ProfileView.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
    
    @State var store : StoreOf<ProfileFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                Text("hi Profile")
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitle("내 정보 수정", displayMode: .inline)
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

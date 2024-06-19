//
//  HomeInitialView.swift
//  Teams
//
//  Created by JinwooLee on 6/18/24.
//

import SwiftUI
import ComposableArchitecture

struct HomeInitialView: View {
    
    let store : StoreOf<HomeInitialFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing : 25) {
                    Text("출시 준비 완료!")
                        .title1()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text(store.nickname + "의 조직을 위해 새로운 새싹톡 워크스페이스를 시작할 준비가 완료되었어요!")
                        .multilineTextAlignment(.center)
                        .bodyRegular()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 150)
                
                Image(.launching)
                    .frame(width: 368, height: 368)
                
                Spacer()
                
                Button("워크스페이스 생성") {
                    store.send(.createWorkspaceTapped)
                }
                .tint(.brandWhite)
                .frame(width: 345, height: 44)
                .title2()
                .background(.brandGreen)
                .cornerRadius(8)
                .padding()
                .navigationBarTitle("시작하기", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {
                            store.send(.goToHomeView)
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
    HomeInitialView(store: Store(initialState: HomeInitialFeature.State(nickname: "옹골찬 고래밥"), reducer: {
        HomeInitialFeature();
    }))
}

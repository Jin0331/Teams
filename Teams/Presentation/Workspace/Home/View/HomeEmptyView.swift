//
//  HomeEmptyView.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import SwiftUI

struct HomeEmptyView: View {
    
    let store : StoreOf<HomeEmptyFeature>
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing : 25) {
                    Text("워크스페이스를 찾을 수 없어요.")
                        .title1()
                        .frame(maxWidth: .infinity, alignment: .center)
                    Text("관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나 새로운 워크스페이스를 생성해주세요. ")
                        .multilineTextAlignment(.center)
                        .bodyRegular()
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                .frame(height: 150)
                
                Image(.workspaceEmpty)
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
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(.empty)
                            Text("No Workspace")
                                .title1()
                            Spacer()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            store.send(.profileButtonTapped)
                        }) {
                            Image(systemName: "person.circle")
                                .frame(width: 32, height: 32)
                                .font(.title) // 버튼 아이콘 크기 설정
                                .tint(.brandBlack)
                        }
                    }
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            store.send(.openSideMenu)
                        } else if value.translation.width < -100 {
                            store.send(.closeSideMenu)
                        }
                    }
            )
        }
    }
}

#Preview {
    HomeEmptyView(store: Store(initialState: HomeEmptyFeature.State(), reducer: {
        HomeEmptyFeature()
    }))
}

//
//  HomeEmptyView.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import Kingfisher
import SwiftUI

struct HomeEmptyView: View {
    
    let store : StoreOf<HomeEmptyFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    Text("워크스페이스를 찾을 수 없어요.")
                        .title1()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 15)
                    Text("관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나 새로운 워크스페이스를 생성해주세요. ")
                        .multilineTextAlignment(.center)
                        .bodyRegular()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    Image(.workspaceEmpty)
                        .frame(width: 368, height: 368)
                        .padding(.bottom, 20)
                    
                    Button("워크스페이스 생성") {
                        store.send(.buttonTapped(.createWorkspaceTapped))
                    }
                    .tint(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(.brandGreen)
                    .cornerRadius(8)
                    .padding()
                    
                    Spacer()
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            Image(.empty)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 34, height: 34) //resize
                            Text("No Workspace")
                                .title1()
                            Spacer()
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            KFImage.url(store.profileImage)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 34, height: 34) //resize
                                .clipShape(Circle())
                                .overlay(
                                    Circle().stroke(.brandGray, lineWidth: 2.5)
                                )
                        }
                        .onTapGesture {
                            store.send(.buttonTapped(.profileOpenTapped))
                        }
                    }
                }
            }
            .animation(.default, value: store.profileImage)
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
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

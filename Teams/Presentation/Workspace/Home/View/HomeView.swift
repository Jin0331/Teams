//
//  HomeView.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher
import RealmSwift

struct HomeView: View {
    
    @State var store : StoreOf<HomeFeature>
    @ObservedResults(DMChatListModel.self) var chatListTable
    
    var body: some View {
        
        WithPerceptionTracking {
            
            //TODO: - scroll View
            NavigationStack {
                ScrollView {
                    VStack {
                        //TODO: - DisclosureGroup 커스텀뷰 생성해야됨
                        Divider().background(.brandWhite).padding(.top, 10)
                        
                        CustomDisclosureGroupView(store: store)
                        
                        Divider().background(Color.viewSeperator)
                        
                        DMListView()
                        
                        Divider().background(Color.viewSeperator)
                        
                        HStack {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .padding(.leading, 15)
                            Text("팀원 추가")
                                .bodyRegular()
                        }
                        .padding()
                        .frame(width: 393, height: 41, alignment: .leading)
                        .padding(.horizontal, 15)
                        .onTapGesture {
                            store.send(.buttonTapped(.inviteMemberButtonTapped))
                        }
                        
                        Spacer()
                    }
                }
                .padding(.trailing, 25)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            if let workspace = store.workspaceCurrent {
                                KFImage.url(workspace.coverImageToUrl)
                                    .requestModifier(AuthManager.kingfisherAuth())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 32, height: 32) //resize
                                    .cornerRadius(8)
                                Text(workspace.name)
                                    .title1()
                                Spacer()
                            }
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
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
}

extension HomeView {
    fileprivate func DMListView() -> some View {
        return DisclosureGroup(isExpanded: $store.dmlListExpanded) {
            VStack {
                ForEach(chatListTable, id: \.id) { chatList in
                    
                    if store.workspaceCurrent!.workspaceID == chatList.workspaceID {
                        HStack {
                            KFImage.url(chatList.user?.profileImageToUrl)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 24, height: 24)
                                .cornerRadius(8)
                            
                            if  chatList.unreadCount >= 1 {
                                Text(chatList.user!.nickname)
                                    .bodyBold()
                            } else {
                                Text(chatList.user!.nickname)
                                    .bodyRegular()
                            }
                            
                            Spacer()
                            
                            if chatList.unreadCount >= 1 {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.brandGreen)
                                    .frame(width: 19, height: 18)
                                    .overlay {
                                        Text(String(chatList.unreadCount))
                                            .font(.caption)
                                            .foregroundStyle(.brandWhite)
                                    }
                            }
                            
                        }
                        .padding(.leading, 30)
                        .onTapGesture {
                            if let user = chatList.user {
                                store.send(.buttonTapped(.dmUserButtonTapped(user.userID)))
                            }
                        }
                    }
                }
                
                HStack {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 18, height: 18)
                        .padding(.leading, 15)
                    Text("새 메세지 시작")
                        .bodyRegular()
                }
                .padding(.leading, 15)
                .frame(width: 393, height: 41, alignment: .leading)
                .onTapGesture {
                    print("hi")
                }
                
            }
            
        } label: {
            Text("다이렉트 메세지")
                .title2()
                .foregroundColor(.brandBlack)
                .frame(height: 56)
                .padding(.leading, 25)
        }
        .tint(.brandBlack)
        .padding(.horizontal, 15)
    }
}

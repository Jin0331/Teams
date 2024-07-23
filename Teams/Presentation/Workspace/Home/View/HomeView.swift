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
import FloatingButton

struct HomeView: View {
    
    @State var store : StoreOf<HomeFeature>
    @ObservedResults(ChannelChatListModel.self, sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: true)) var channelChatListTable
    @ObservedResults(DMChatListModel.self, sortDescriptor: SortDescriptor(keyPath: "createdAt", ascending: true)) var dmChatListTable
    
    var body: some View {
        
        WithPerceptionTracking {
            
            //TODO: - scroll View
            NavigationStack {
                ZStack(alignment:.bottomTrailing) {
                    ScrollView {
                        VStack {
                            //TODO: - DisclosureGroup 커스텀뷰 생성해야됨
                            Divider().background(.brandWhite).padding(.top, 10)
                            
                            ChannelListView()
                            
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
                    
                    FloatingButton(mainButtonView: HomeFloatingButton(), buttons: [
                        IconAndTextButton(imageName: "paperplane.circle", buttonText: "다이렉트 메세지")
                            .onTapGesture(perform: {
                                store.send(.buttonTapped(.newMessageButtonTapped))
                            }),
                        IconAndTextButton(imageName: "list.bullet.circle", buttonText: "채널 메세지")
                            .onTapGesture(perform: {
                                store.send(.buttonTapped(.channelSearchButtonTapped))
                            })
                    ])
                    .straight()
                    .direction(.top)
                    .alignment(.right)
                    .spacing(3)
                    .initialOpacity(0)
                    .offset(x: 25, y: -18)
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
                        .onTapGesture {
                            print("SideMenu Open")
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(alignment:.center) {
                            if let workspace = store.workspaceCurrent {
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
                        }
                        .onTapGesture {
                            store.send(.buttonTapped(.profileOpenTapped))
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
    private func ChannelListView() -> some View {
        return WithPerceptionTracking {
            DisclosureGroup(isExpanded: $store.channelListExpanded) {
                VStack {
                    ForEach(channelChatListTable, id: \.id) { channel in
                        if let workspaceCurrent = store.workspaceCurrent, workspaceCurrent.workspaceID == channel.workspaceID {
                            HStack {
                                Image(systemName: "number")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .padding(.leading, 15)
                                
                                if  channel.unreadCount >= 1 && channel.lastChatUser! != UserDefaultManager.shared.userId {
                                    Text(channel.channelName)
                                        .bodyBold()
                                } else {
                                    Text(channel.channelName)
                                        .bodyRegular()
                                }
                                
                                Spacer()
                                
                                if channel.unreadCount >= 1 && channel.lastChatUser! != UserDefaultManager.shared.userId {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brandGreen)
                                        .frame(width: 19, height: 18)
                                        .overlay {
                                            Text(String(channel.unreadCount))
                                                .font(.caption)
                                                .foregroundStyle(.brandWhite)
                                        }
                                }
                            }
                            
                            .padding(.horizontal, 15)
                            .frame(width: 393, height: 41, alignment: .leading)
                            .onTapGesture {
                                store.send(.channelEnter(channel.toChannel))
                            }
                        }
                    }
                    
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .padding(.leading, 15)
                        Text("채널 추가")
                            .bodyRegular()
                    }
                    .padding(.horizontal, 15)
                    .frame(width: 393, height: 41, alignment: .leading)
                    .onTapGesture {
                        store.send(.buttonTapped(.channelAddButtonTapped))
                    }
                }
                
            } label: {
                Text("채널")
                    .title2()
                    .foregroundColor(.brandBlack)
                    .frame(height: 56)
                    .padding(.leading, 25)
            }
            .tint(.brandBlack)
            .padding(.horizontal, 15)
            .confirmationDialog("", isPresented: $store.showingChannelActionSheet) {
                Button("채널 생성") {
                    store.send(.buttonTapped(.channelCreateButtonTapped))
                }
                Button("채널 탐색") {
                    store.send(.buttonTapped(.channelSearchButtonTapped))
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
    
    private func DMListView() -> some View {
        return WithPerceptionTracking {
            DisclosureGroup(isExpanded: $store.dmlListExpanded) {
                VStack {
                    ForEach(dmChatListTable, id: \.id) { chatList in
                        if let workspaceCurrent = store.workspaceCurrent, workspaceCurrent.workspaceID == chatList.workspaceID {
                            HStack {
                                KFImage.url(chatList.user?.profileImageToUrl)
                                    .requestModifier(AuthManager.kingfisherAuth())
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 24, height: 24)
                                    .cornerRadius(8)
                                
                                if  chatList.unreadCount >= 1 && chatList.lastChatUser! != UserDefaultManager.shared.userId {
                                    Text(chatList.user!.nickname)
                                        .bodyBold()
                                } else {
                                    Text(chatList.user!.nickname)
                                        .bodyRegular()
                                }
                                
                                Spacer()
                                
                                if chatList.unreadCount >= 1 && chatList.lastChatUser! != UserDefaultManager.shared.userId {
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
                    .padding(.vertical, 10)
                    
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
                        store.send(.buttonTapped(.newMessageButtonTapped))
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
}

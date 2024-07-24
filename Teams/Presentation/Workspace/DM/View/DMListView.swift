//
//  DMListView.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import RealmSwift

struct DMListView : View {
    
    @State var store : StoreOf<DMListFeature>
    @ObservedResults(DMChatListModel.self) var chatListTable
    
    var body : some View {
        
        WithPerceptionTracking {
            
            NavigationStack {
                VStack {
                    Divider().background(.brandWhite).padding(.top, 10)
                    
                    switch store.viewType {
                    case .loading:
                        VStack {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                                .scaleEffect(1.2, anchor: .center)
                                .padding()
                            Spacer()
                        }
                    case .empty:
                        Spacer()
                        DMListemptyView()
                        
                    case .normal:
                        DMListSubView()
                    }
                    
                    Spacer()
                }
            }
            .animation(.default, value: store.viewType)
            .task {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    store.send(.onAppear)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if let workspace = store.currentWorkspace {
                            KFImage.url(workspace.coverImageToUrl)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32) //resize
                                .cornerRadius(8)
                            Text("다이렉트 메세지")
                                .title1()
                            Spacer()
                        }
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(alignment:.center) {
                        if let workspace = store.currentWorkspace {
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
    }
}

extension DMListView {
    private func DMListemptyView() -> VStack<TupleView<(some View, some View, some View)>> {
        return VStack(spacing : 25) {
            Text("워크스페이스에\n멤버가 없어요.")
                .title1()
                .multilineTextAlignment(.center)
            
            Text("새로운 팀원을 초대해보세요.")
                .bodyRegular()
            
            Image(.dmListButton)
                .asButton {
                    store.send(.buttonTapped(.inviteMemberButtonTapped))
                }
        }
    }
    
    private func DMListSubView() -> VStack<TupleView<(some View, some View, some View)>> {
        return VStack {
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing : 25) {
                    ForEach(store.workspaceMember, id: \.id) { member in
                        VStack(alignment : .center, spacing: 5) {
                            KFImage.url(member.profileImageToUrl)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .cornerRadius(8)
                            Text(member.nickname)
                                .bodyRegular()
                        }
                        .onTapGesture {
                            store.send(.buttonTapped(.dmUserButtonTapped(member.userID)))
                        }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 100)
            
            Divider().background(.brandWhite).padding(.horizontal, 5)
            
            List {
                ForEach(chatListTable, id: \.id) { chatList in
                    
                    if let currentWorkspace = store.currentWorkspace, currentWorkspace.workspaceID == chatList.workspaceID {
                        HStack {
                            KFImage.url(chatList.user?.profileImageToUrl)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 44, height: 44)
                                .cornerRadius(8)
                            
                            VStack(alignment:.leading, spacing : 10) {
                                Text(chatList.user!.nickname)
                                    .font(.caption)
                                Text(chatList.content ?? "")
                                    .font(.caption2)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(chatList.createdAtToString)
                                    .font(.caption2)
                                
                                if chatList.unreadCount >= 1 && chatList.lastChatUser! != UserDefaultManager.shared.userId {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(.brandGreen)
                                        .frame(width: 18, height: 18)
                                        .overlay {
                                            Text(String(chatList.unreadCount))
                                                .font(.caption)
                                                .foregroundStyle(.brandWhite)
                                        }
                                }
                            }
                        }
                        .onTapGesture {
                            if let user = chatList.user {
                                store.send(.buttonTapped(.dmUserButtonTapped(user.userID)))
                            }
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
            .listStyle(.plain)
        }
    }
}

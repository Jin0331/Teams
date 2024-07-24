//
//  SearchView.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct SearchView: View {
    
    @Perception.Bindable var store : StoreOf<SearchFeature>
    @State private var topExpanded: Bool = true
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                ScrollView {
                    VStack {
                        if store.channels.isEmpty && store.members.isEmpty {
                            VStack {
                                HStack {
                                    Image(systemName: "list.bullet.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.brandInActive)
                                    
                                    Image(systemName: "person.2.circle")
                                        .resizable()
                                        .frame(width: 40, height: 40)
                                        .foregroundColor(.brandInActive)
                                }
                                
                                Text("찾고싶은 채널 또는 멤버를 검색하고 실시간 채팅을 진행해보세요.")
                                    .multilineTextAlignment(.center)
                                    .title2()
                                    .padding()
                                    .foregroundStyle(.brandInActive)
                            }
                            .padding(.top, 100)
                        }
                        
                        if !store.channels.isEmpty {
                            HStack {
                                Image(systemName: "list.bullet.circle")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .padding(.leading, 15)
                                Text("채널")
                                    .title2()
                                Spacer()
                            }.padding()
                            
                            ForEach(store.channels, id: \.id) { channel in
                                HStack {
                                    Image(systemName: "number")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .padding(.leading, 15)
                                    Text(channel.name)
                                        .bodyRegular()
                                    Spacer()
                                }
                                .padding()
                            }
                            
                            Divider().background(.brandWhite)
                        }
                        
                        if !store.members.isEmpty {
                            HStack {
                                Image(systemName: "person.2.circle")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .padding(.leading, 15)
                                Text("멤버")
                                    .title2()
                                Spacer()
                            }.padding()
                            
                            ForEach(store.members, id: \.id) { member in
                                HStack {
                                    KFImage.url(member.profileImageToUrl)
                                        .requestModifier(AuthManager.kingfisherAuth())
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 24, height: 24)
                                        .cornerRadius(8)
                                        .padding(.leading, 15)
                                    Text(member.nickname)
                                        .bodyRegular()
                                    Spacer()
                                }
                                .padding()
                            }
                            
                            Divider().background(.brandWhite)
                        }
                    }
                }
                .searchable(text: $store.searchKeyword, prompt: "채널 또는 멤버를 검색해주세요")
                
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        if let workspace = UserDefaultManager.shared.getWorkspace() {
                            KFImage.url(workspace.coverImageToUrl)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 32, height: 32) //resize
                                .cornerRadius(8)
                        }
                        
                        Text("검색")
                            .title1()
                        Spacer()
                        
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
                        //                        store.send(.buttonTapped(.profileOpenTapped))
                    }
                }
                
            }
        }
    }
}

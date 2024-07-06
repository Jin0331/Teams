//
//  HomeView.swift
//  Teams
//
//  Created by JinwooLee on 6/14/24.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct HomeView: View {
    
    @State var store : StoreOf<HomeFeature>
    @State private var expanded: Bool = false
    
    var body: some View {
        
        WithPerceptionTracking {
            
            //TODO: - scroll View
            
            NavigationStack {
                VStack {
                    //TODO: - DisclosureGroup 커스텀뷰 생성해야됨
                    Divider().background(.brandWhite).padding(.top, 10)
                    
                    DisclosureGroup(isExpanded: $expanded) {
                        VStack {
                            ForEach(store.channelList, id: \.id) { response in
                                HStack {
                                    Image(systemName: "number")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                        .padding(.leading, 5)
                                    Text(response.name)
                                        .bodyRegular()
                                }
                                .padding(.horizontal, 15)
                                .frame(width: 393, height: 41, alignment: .leading)
                                .onTapGesture {
                                    print("hi")
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
                                store.send(.channelCreateButtonTapped)
                            }
                            
                        }
                        
                    } label: {
                        Text("채널")
                            .title2()
                            .foregroundColor(.brandBlack)
                            .frame(height: 56)
                    }
                    .tint(.brandBlack)
                    .padding(.horizontal, 15)
                    
                    Divider().background(Color.viewSeperator)
                    
                    DisclosureGroup(isExpanded: $expanded) {
                        VStack {
                            ForEach(store.dmList, id: \.id) { response in
                                HStack {
                                    Image(systemName: "number")
                                        .resizable()
                                        .frame(width: 18, height: 18)
                                    Text(response.roomID)
                                        .bodyRegular()
                                }
                                .padding(.leading, 15)
                                .frame(width: 393, height: 41, alignment: .leading)
                                .onTapGesture {
                                    print("hi")
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
                    }
                    .tint(.brandBlack)
                    .padding(.horizontal, 15)
                    
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
                        print("hi")
                    }
                    
                    Spacer()
                    
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        HStack {
                            if let workspace = store.workspaceCurrent {
                                KFImage.url(workspace.profileImageToUrl)
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

#Preview {
    HomeView(store: Store(initialState: HomeFeature.State(workspaceCurrent: Workspace(workspaceID: "4e93033c-bedf-4a36-b16b-e16f37f93ae7",
                                                                                      name: "천장zxc",
                                                                                      description: "",
                                                                                      coverImage: "/static/workspaceCoverImages/1720011671324.jpeg",
                                                                                      ownerID: "e1b47086-a781-4885-a9a3-3998ec818fa8",
                                                                                      createdAt: "2024-07-03T12:44:24.083Z")), reducer: {
        HomeFeature()
    }))
}

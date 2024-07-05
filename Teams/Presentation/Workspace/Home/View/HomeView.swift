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
    
    var body: some View {
        
        WithPerceptionTracking {
            
            NavigationStack {
                
                VStack {

                }
             
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

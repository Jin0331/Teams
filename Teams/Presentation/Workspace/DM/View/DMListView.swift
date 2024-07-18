//
//  DMListView.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct DMListView : View {
    
    @State var store : StoreOf<DMListFeature>
    
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
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing : 25) {
                                    ForEach(store.workspaceMember, id: \.id) { member in
                                        VStack(alignment : .center, spacing: 5) {
                                            if member.userID != UserDefaultManager.shared.userId {
                                                KFImage.url(member.profileImageToUrl)
                                                    .requestModifier(AuthManager.kingfisherAuth())
                                                    .resizable()
                                                    .aspectRatio(contentMode: .fill)
                                                    .frame(width: 44, height: 44)
                                                    .cornerRadius(8)
                                                Text(member.nickname)
                                                    .bodyRegular()
                                            }
                                        }
                                        .onTapGesture {
                                            store.send(.buttonTapped(.dmUserButtonTapped(member)))
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                            .frame(height: 100)
                            Divider().background(.brandWhite).padding(.top, 5)
                            
                        }

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
                            Text("Direct Message")
                                .title1()
                            Spacer()
                        }
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
}

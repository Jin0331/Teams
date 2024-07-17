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
                        VStack(spacing : 25) {
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
                        
                    case .normal:
                        Text("empty")
                    }
                    
                    Spacer()
                }
            }
            .animation(.default, value: store.viewType)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
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

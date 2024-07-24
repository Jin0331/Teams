//
//  ProfileOtherView.swift
//  Teams
//
//  Created by JinwooLee on 7/25/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct ProfileOtherView: View {
    
    @State var store : StoreOf<ProfileOtherFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            NavigationStack {
                VStack {
                    if let otherProfile = store.otherProfile {
                        Divider().background(.brandWhite).padding(.top, 10)
                        
                        KFImage.url(otherProfile.profileImageToUrl)
                                .requestModifier(AuthManager.kingfisherAuth())
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 232, height: 232) //resize
                                .cornerRadius(8)
                        
                        Form {
                            HStack(spacing: 5) {
                                Text("닉네임")
                                    .bodyBold()
                                Spacer()
                                Text(otherProfile.nickname)
                                    .bodyRegular()
                                    .foregroundStyle(.textSecondary)
                            }
                            
                            HStack(spacing: 5) {
                                Text("이메일")
                                    .bodyBold()
                                Spacer()
                                Text(otherProfile.email)
                                    .bodyRegular()
                                    .foregroundStyle(.textSecondary)
                            }
                        }
                        .scrollDisabled(true)
                        .scrollContentBackground(.hidden)
                        
                        Spacer()
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("프로필")
                            .title2()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.goback)
                    }, label: {
                        Image(.chevron)
                            .resizable()
                            .frame(width: 14, height: 19)
                    })
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
            
        }
    }
}

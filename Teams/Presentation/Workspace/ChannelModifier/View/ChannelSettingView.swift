//
//  ChannelSettingView.swift
//  Teams
//
//  Created by JinwooLee on 7/15/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher

struct ChannelSettingView: View {
    
    let store : StoreOf<ChannelSettingFeature>
    @State private var expanded: Bool = false
    
    let columns = [
      //추가 하면 할수록 화면에 보여지는 개수가 변함
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        WithPerceptionTracking {
            
            NavigationStack {
                Divider().background(.brandWhite)
                
                VStack {
                    Text("# " + store.channelCurrent!.name)
                        .title2()
                        .frame(maxWidth: .infinity, maxHeight: 18, alignment: .leading)
                        .padding(15)
                    
                    Text(store.channelCurrent!.description)
                        .bodyRegular()
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 15)
                    
                    DisclosureGroup(isExpanded: $expanded) {
                        LazyVGrid(columns: columns) {
                            ForEach(store.channelCurrentMemebers!, id: \.id) { user in
                                VStack {
                                    KFImage.url(user.profileImageToUrl)
                                        .requestModifier(AuthManager.kingfisherAuth())
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 44, height: 44)
                                        .cornerRadius(8)
                                    Text(user.nickname)
                                        .bodyRegular()
                                }
                            }
                        }
                        
                    } label: {
                        Text("멤버 (\(store.channelCurrentMemebers!.count))")
                            .title2()
                            .foregroundColor(.brandBlack)
                            .frame(height: 56)
                    }
                    .tint(.brandBlack)
                    .padding(.horizontal, 15)
                    
                }
                
                Spacer()
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationBarTitle("채널 설정", displayMode: .inline)
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.goBack)
                    }, label: {
                        Image(.chevron)
                            .resizable()
                            .frame(width: 14, height: 19)
                    })
                }
            }
        }
    }
}

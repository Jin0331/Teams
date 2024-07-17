//
//  ChannelSettingView.swift
//  Teams
//
//  Created by JinwooLee on 7/15/24.
//

import SwiftUI
import ComposableArchitecture
import Kingfisher
import PopupView

struct ChannelSettingView: View {
    
    @State var store : StoreOf<ChannelSettingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            
            NavigationStack {
                
                Divider().background(.brandWhite)
                
                ScrollView {
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
                        
                        memberView()
                            .padding(.bottom, 15)
                        
                        ChannelSettingButtonView(store: store)
                        
                        Spacer()
                    }
                }
                
            }
            .popup(item: $store.popupPresent) { popup in
                PopupButtonChannelSettingView(store: store, action: popup)
            } customize: {
                $0
                    .isOpaque(true)
                    .closeOnTap(false)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.4))
            }
            .task {
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

extension ChannelSettingView {
    fileprivate func memberView() -> some View {
        let columns = [
            //추가 하면 할수록 화면에 보여지는 개수가 변함
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        
        return DisclosureGroup(isExpanded: $store.expanded) {
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
}

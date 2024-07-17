//
//  ChannelOwnerChangeView.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import ComposableArchitecture
import SwiftUI
import PopupView
import Kingfisher

struct ChannelOwnerChangeView: View {
    
    @State var store : StoreOf<ChannelOwnerChangeFeature>
    var body: some View {
        
        WithPerceptionTracking {
            
            NavigationStack {
                Divider().background(.brandWhite)
                    .padding(.bottom, 5)
                
                ScrollView {
                    ForEach(store.channelCurrentMembers, id: \.id) { member in
                        
                        if member.userID != store.channelCurrent!.ownerID {
                            CellView(member)
                                .onTapGesture {
                                    store.send(.listTapped(member))
                                }
                        }
                    }
                }
                .onAppear {
                    store.send(.onAppear)
                }
                .navigationBarTitle("채널 관리자 변경", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {
                            store.send(.dismiss)
                        } label : {
                            Image("Vector")
                        }
                )
                .navigationBarColor(backgroundColor: .brandWhite, titleColor: .brandBlack)
                .navigationViewStyle(StackNavigationViewStyle())
            }
            .popup(item: $store.popupPresent) { popup in
                PopupButtonChannelOwnerChangeView(store: store, action: popup)
            } customize: {
                $0
                    .isOpaque(true)
                    .closeOnTap(false)
                    .closeOnTapOutside(true)
                    .backgroundColor(.black.opacity(0.4))
            }
        }
    }
}

extension ChannelOwnerChangeView {
    fileprivate func CellView(_ member: User) -> some View {
        return HStack {
            KFImage.url(member.profileImageToUrl)
                .requestModifier(AuthManager.kingfisherAuth())
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 44, height: 44)
                .cornerRadius(8)
                .padding(.leading, 10)
            
            VStack(alignment : .leading) {
                Text(member.nickname)
                    .bodyBold()
                Text(member.email)
                    .bodyRegular()
            }
        }
        .frame(width: 393, height: 60, alignment: .leading)
        .padding(.leading, 10)
    }
    
}

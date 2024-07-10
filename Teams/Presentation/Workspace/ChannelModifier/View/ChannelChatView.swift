//
//  ChannelChatView.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import SwiftUI
import ExyteChat
import ComposableArchitecture

struct ChannelChatView: View {
    @State var store : StoreOf<ChannelChatFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            Divider().background(.brandWhite)
            ChatView(messages: store.message, chatType: .conversation) { draft in
                store.send(.sendMessage(draft))
            }
            .onAppear {
                store.send(.onAppear)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.socket(.socketDisconnect))
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

//#Preview {
//    ChannelChatView()
//}

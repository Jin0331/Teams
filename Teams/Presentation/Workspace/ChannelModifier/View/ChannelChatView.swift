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
            ChatView(messages: store.message, chatType: .conversation) { draft in
                store.send(.sendMessage(draft))
            }
            .onAppear {
                store.send(.onAppear)
            }
            .onDisappear {
                print("???")
                store.send(.socketDisconnect)
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
}

//#Preview {
//    ChannelChatView()
//}

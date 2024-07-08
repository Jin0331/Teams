//
//  ChannelChatView.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import SwiftUI
import ComposableArchitecture

struct ChannelChatView: View {
    @State var store : StoreOf<ChannelChatFeature>
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                store.send(.onAppear)
            }
    }
}

//#Preview {
//    ChannelChatView()
//}

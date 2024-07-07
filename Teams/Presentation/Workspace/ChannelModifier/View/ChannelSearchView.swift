//
//  ChannelSearchView.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import ComposableArchitecture
import SwiftUI
import PopupView

struct ChannelSearchView: View {
    
    @State var store : StoreOf<ChannelSearchFeature>
    
    var body: some View {
        WithPerceptionTracking {
            NavigationStack {
                Divider().background(.brandWhite).padding(.top, 10)
                VStack(spacing: 10) {
                    ForEach(store.channelList, id: \.id) { response in
                        HStack {
                            Image(systemName: "number")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .padding(.leading, 15)
                            Text(response.name)
                                .bodyBold()
                        }
                        .padding(.horizontal, 15)
                        .frame(width: 393, height: 41, alignment: .leading)
                        .onTapGesture {
                            print("hi")
                        }
                    }
                    Spacer()
                }
                .navigationBarTitle("채널 탐색", displayMode: .inline)
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
            .onAppear {
                store.send(.onAppear)
            }
        }
    }
    
}

#Preview {
    ChannelSearchView(store: Store(initialState: ChannelSearchFeature.State(), reducer: {
        ChannelSearchFeature()
    }))
}

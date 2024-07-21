//
//  CustomDisclosureGroupView.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

import Foundation
import ComposableArchitecture
import SwiftUI

struct CustomDisclosureGroupView : View {
    @Perception.Bindable var store: StoreOf<HomeFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            DisclosureGroup(isExpanded: $store.channelListExpanded) {
                VStack {
                    ForEach(store.channelList, id: \.id) { channel in
                        HStack {
                            Image(systemName: "number")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .padding(.leading, 15)
                            Text(channel.name)
                                .bodyRegular()
                        }
                        .padding(.horizontal, 15)
                        .frame(width: 393, height: 41, alignment: .leading)
                        .onTapGesture {
                            store.send(.channelEnter(channel))
                        }
                    }
                    
                    HStack {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 18, height: 18)
                            .padding(.leading, 15)
                        Text("채널 추가")
                            .bodyRegular()
                    }
                    .padding(.horizontal, 15)
                    .frame(width: 393, height: 41, alignment: .leading)
                    .onTapGesture {
                        store.send(.buttonTapped(.channelAddButtonTapped))
                    }
                }
                
            } label: {
                Text("채널")
                    .title2()
                    .foregroundColor(.brandBlack)
                    .frame(height: 56)
                    .padding(.leading, 25)
            }
            .tint(.brandBlack)
            .padding(.horizontal, 15)
            .confirmationDialog("", isPresented: $store.showingChannelActionSheet) {
                Button("채널 생성") {
                    store.send(.buttonTapped(.channelCreateButtonTapped))
                }
                Button("채널 탐색") {
                    store.send(.buttonTapped(.channelSearchButtonTapped))
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

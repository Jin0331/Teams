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
    @State private var showingSheet : Bool = false
    
    var body: some View {
        
        WithPerceptionTracking {
            DisclosureGroup(isExpanded: $store.channelListExpanded) {
                VStack {
                    ForEach(store.channelList, id: \.id) { response in
                        HStack {
                            Image(systemName: "number")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .padding(.leading, 15)
                            Text(response.name)
                                .bodyRegular()
                        }
                        .padding(.horizontal, 15)
                        .frame(width: 393, height: 41, alignment: .leading)
                        .onTapGesture {
                            print("hi")
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
                        store.send(.channelAddButtonTapped)
                    }
                }
                
            } label: {
                Text("채널")
                    .title2()
                    .foregroundColor(.brandBlack)
                    .frame(height: 56)
            }
            .tint(.brandBlack)
            .padding(.horizontal, 15)
            .confirmationDialog("", isPresented: $store.showingChannelActionSheet) {
                Button("채널 생성") {
                    store.send(.channelCreateButtonTapped)
                }
                Button("채널 탐색") {
                    store.send(.channelSearchButtonTapped)
                }
                Button("취소", role: .cancel) {}
            }
        }
    }
}

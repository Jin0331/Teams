//
//  ChannelSettingView.swift
//  Teams
//
//  Created by JinwooLee on 7/15/24.
//

import SwiftUI
import ComposableArchitecture

struct ChannelSettingView: View {
    
    let store : StoreOf<ChannelSettingFeature>
    
    var body: some View {
        WithPerceptionTracking {
            
            NavigationStack {
                Divider().background(.brandWhite)
                
                VStack {
                    Text("hi")
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

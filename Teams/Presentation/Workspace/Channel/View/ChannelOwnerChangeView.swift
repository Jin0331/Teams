//
//  ChannelOwnerChangeView.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import ComposableArchitecture
import SwiftUI
import PopupView

struct ChannelOwnerChangeView: View {
    
    @State var store : StoreOf<ChannelOwnerChangeFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            
            NavigationStack {
                Divider().background(.brandWhite)
                    .padding(.bottom, 15)
                
                ScrollView {
                    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                }
            }
            .onAppear {
                store.send(.onAppear)
            }
//            .popup(item: $store.toastPresent) { text in
//                ToastView(text: text.rawValue)
//            } customize: {
//                $0.autohideIn(2)
//            }
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
    }
}

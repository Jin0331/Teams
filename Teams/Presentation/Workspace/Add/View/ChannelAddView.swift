//
//  ChannelAddView.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

import ComposableArchitecture
import SwiftUI
import PopupView

struct ChannelAddView : View {
    
    @State var store : StoreOf<ChannelAddFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            Divider().background(.brandWhite).padding(.top, 10)
            NavigationStack {
                VStack(spacing: 20) {
                    Text("채널 이름")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .padding()
                        .frame(width: 345, height: 24, alignment: .leading)
                    
                    TextField("채널 이름을 입력하세요 (필수)", text: $store.channelName)
                        .bodyRegular()
                        .padding()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Text("채널 설명")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .padding()
                        .frame(width: 345, height: 24, alignment: .leading)
                    
                    TextField("채널을 설명하세요 (옵션)", text: $store.channelDescription)
                        .bodyRegular()
                        .padding()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Button("생성") {
                        store.send(.createButtonTapped)
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 345, height: 44)
                    .title2()
                    .background(backgroundForIsActive(store.createButton))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .disabled(!store.createButton)
                    
                    Spacer()
                    
                }
                .popup(item: $store.toastPresent) { text in
                    ToastView(text: text.rawValue)
                } customize: {
                    $0.autohideIn(2)
                }
                .navigationBarTitle("채널 생성", displayMode: .inline)
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
}


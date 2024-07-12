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
                Task {
                    store.send(.sendMessage(draft))
                }
            } inputViewBuilder: { textBinding, attachments, inputViewState, inputViewStyle, inputViewActionClosure, dismissKeyboardClosure in
                Group {
                    switch inputViewStyle {
                    case .message: // input view on chat screen
                        VStack {
                            HStack {
                                Image(.plus)
                                    .resizable()
                                    .frame(width: 22, height: 20)
                                    .padding(.horizontal, 5)
                                    .asButton {
                                        print("hihi")
                                    }
                                TextField("메세지를 입력하세요", text: textBinding, axis: .vertical)
                                    .bodyRegular()
                                Image(.send)
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .padding(.horizontal, 5)
                                    .asButton {
                                        print("hihi")
                                    }
                            }
                            .padding(/*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                            .background(Color(hex: 0xf6f6f6))
                            .cornerRadius(8)
                            .padding()
                            
                        }
                        
                        
                    case .signature: // input view on photo selection screen
                        VStack {
                            HStack {
                                Button("Send") { inputViewActionClosure(.send) }
                            }
                            TextField("Compose a signature for photo", text: textBinding)
                                .background(Color.green)
                        }
                    }
                }
            }
            
            
            .setAvailableInput(.textAndMedia)
            .assetsPickerLimit(assetsPickerLimit: 5)
            .showNetworkConnectionProblem(true)
            .onAppear {
                store.send(.onAppear)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        Text("# " + store.channelCurrent.name)
                            .title2()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        store.send(.socket(.socketDisconnect))
                    }, label: {
                        Image(.chevron)
                            .resizable()
                            .frame(width: 14, height: 19)
                    })
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        print("편집화면")
                    }, label: {
                        Image(.list)
                            .resizable()
                            .frame(width: 18, height: 15.92)
                    })
                }
            }
        }
    }
}

//
//  SideMenuView.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import SwiftUI
import ComposableArchitecture

struct SideMenuView: View {
    
    @State var store : StoreOf<SideMenuFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            VStack {
                switch store.showList {
                case .success :
                    List {
                        ForEach(store.workspaceList, id: \.id) { response in
                            WorkspaceListItemView(response: response, userID: UserDefaultManager.shared.userId!, store: store)
                                .onTapGesture {
                                    print("", UserDefaultManager.shared.userId!, response.ownerID)
                                }
                        }
                        .listRowSeparator(.hidden)
                        .cornerRadius(8)
                    }

                    .listStyle(.plain)
                    .scrollDisabled(store.listScroll)
                case .failed:
                    Text("워크스페이스를 찾을 수 없어요.")
                        .title1()
                        .multilineTextAlignment(.center)
                        .frame(width: 269, height: 60, alignment: .center)
                        .padding(.top, 100)
                    
                    Text("관리자에게 초대를 요청하거나, 다른 이메일로 시도하거나 새로운 워크스페이스를 생성해주세요.")
                        .bodyRegular()
                        .multilineTextAlignment(.center)
                        .frame(width: 269, height: 75, alignment: .center)
                    
                    Button("워크스페이스 생성") {
                        store.send(.createWorkspaceTapped)
                    }
                    .tint(.brandWhite)
                    .frame(width: 269, height: 44)
                    .title2()
                    .background(.brandGreen)
                    .cornerRadius(8)
                    .backgroundStyle(.brandWhite)
                case .loading :
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(1.2, anchor: .center)
                            .padding()
                        Spacer()
                    }
                }
                
                Spacer()
                
                VStack {
                    Button(action: {
                        store.send(.createWorkspaceTapped)
                    }, label: {
                        HStack {
                            Image(.plus)
                            Text("워크스페이스 추가")
                                .bodyRegular()
                                .tint(.secondary)
                                .frame(width: 115, height: 28, alignment: .leading)
                            Spacer()
                        }
                    })
                    .padding(.leading, 20)
                    
                    Button(action: {}, label: {
                        HStack {
                            Image(.help)
                            Text("도움말")
                                .bodyRegular()
                                .tint(.secondary)
                                .frame(width: 115, height: 28, alignment: .leading)
                            Spacer()
                        }
                    })
                    .padding(.leading, 20)
                }
            }
            .animation(.default, value: store.showList)
            .customNavigationBar(title: "워크스페이스", height: 98)
            .background(.brandWhite)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                store.send(.onAppear)
            }
        }
    }
}


struct RoundedCornerShape: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

//#Preview {
//    SideMenuView(store: Store(initialState: SideMenuFeature.State(), reducer: {
//        SideMenuFeature()
//    }))
//}

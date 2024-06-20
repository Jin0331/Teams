//
//  WorkspaceAddView.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import ComposableArchitecture
import SwiftUI

struct WorkspaceAddView : View {
    
    @State var store : StoreOf<WorkspaceAddFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            NavigationStack {
                VStack(spacing: 20) {
                    
                    Button(action: {
                        
                    }, label: {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.brandGreen)
                                .frame(width: 70, height: 70)
                                .padding()
                            Image(.workspace)
                                .resizable()
                                .frame(width: 48, height: 60)
                                .offset(y: 5)
                            Image(.camera)
                                .resizable()
                                .frame(width: 24, height: 24)
                                .offset(x: 30, y: 30)
                        }
                    })
                    
                    Text("워크스페이스 이름")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .padding()
                        .frame(width: 345, height: 24, alignment: .leading)
                    
                    TextField("워크스페이스 이름을 입력하세요 (필수)", text: $store.workspaceName)
                        .bodyRegular()
                        .padding()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Text("워크스페이스 설명")
                        .title2()
                        .foregroundStyle(.brandBlack)
                        .padding()
                        .frame(width: 345, height: 24, alignment: .leading)
                    
                    TextField("워크스페이스를 설명하세요 (옵션)", text: $store.workspaceDescription)
                        .bodyRegular()
                        .padding()
                        .frame(width: 345, height: 44, alignment: .leading)
                    
                    Button("완료") {
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
                .navigationBarTitle("워크스페이스 생성", displayMode: .inline)
                .navigationBarItems(
                    leading:
                        Button {

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

#Preview {
    WorkspaceAddView(store: Store(initialState: WorkspaceAddFeature.State(), reducer: {
        WorkspaceAddFeature()
    }))
}

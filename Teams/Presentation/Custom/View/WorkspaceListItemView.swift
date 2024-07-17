//
//  WorkspaceListItemView.swift
//  Teams
//
//  Created by JinwooLee on 7/1/24.
//

import ComposableArchitecture
import SwiftUI
import Kingfisher

struct WorkspaceListItemView: View {
    let workspace: Workspace
    let userID : String
    @Perception.Bindable var store: StoreOf<SideMenuFeature>
    @State private var showingSheet : Bool = false
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                KFImage.url(workspace.coverImageToUrl)
                    .requestModifier(AuthManager.kingfisherAuth())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .cornerRadius(8)
                    .padding(.leading, 10)
                
                VStack(alignment:.leading, spacing : 5) {
                    Text(workspace.name)
                        .bodyBold()
                    Text(workspace.createdAtToString)
                        .bodyRegular()
                        .foregroundStyle(Color.secondary)
                }
                .frame(width: 192, alignment: .leading)
                
                if workspace.id == store.workspaceIdCurrent {
                    Image(.listEdit)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            showingSheet = true
                        }
                }
            }
            .frame(width: 305, height: 72, alignment: .leading)
            .background(workspace.id == store.workspaceIdCurrent ? .brandGray : .brandWhite)
            .confirmationDialog("", isPresented: $showingSheet) {
                //TODO: - Button 선택에 따른 기능 구현 필요
                if workspace.ownerID == userID {
                    Button("워크스페이스 편집") {
                        store.send(.workspaceEdit(workspace))
                    }
                    Button("워크스페이스 나가기") {
                        store.send(.workspaceExitManager)
                    }
                    Button("워크스페이스 관리자 변경") {}
                    Button("워크스페이스 삭제") {
                        store.send(.workspaceRemoveButtonTapped)
                    }
                } else {
                    Button("워크스페이스 나가기") {
                        store.send(.workspaceExitButtonTapped)
                    }
                }
                
                Button("취소", role: .cancel) {}
            }
        }
    }
}

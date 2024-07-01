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
    let response: Workspace
    @Perception.Bindable var store: StoreOf<SideMenuFeature>
    @Binding var showingSheet : Bool
    
    var body: some View {
        WithPerceptionTracking {
            HStack {
                KFImage.url(response.profileImageToUrl)
                    .requestModifier(AuthManager.kingfisherAuth())
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 44, height: 44)
                    .cornerRadius(8)
                    .padding(.leading, 10)
                
                VStack(alignment:.leading, spacing : 5) {
                    Text(response.name)
                        .bodyBold()
                    Text(response.createdAtToString)
                        .bodyRegular()
                        .foregroundStyle(Color.secondary)
                }
                .frame(width: 192, alignment: .leading)
                
                if response.id == store.workspaceIdCurrent {
                    Image(.listEdit)
                        .resizable()
                        .frame(width: 20, height: 20)
                        .onTapGesture {
                            showingSheet = true
                        }
                }
            }
            .frame(width: 305, height: 72, alignment: .leading)
            .background(response.id == store.workspaceIdCurrent ? .brandGray : .brandWhite)
            .confirmationDialog("", isPresented: $showingSheet) {
                if response.ownerID == UserDefaultManager.shared.userId! {
                    Button("워크스페이스 편집") {}
                    Button("워크스페이스 나가기") {}
                    Button("워크스페이스 관리자 변경") {}
                    Button("워크스페이스 삭제") {}
                } else {
                    Button("워크스페이스 나가기") {}
                }
                
                Button("취소", role: .cancel) {}
            }
        }
    }
}

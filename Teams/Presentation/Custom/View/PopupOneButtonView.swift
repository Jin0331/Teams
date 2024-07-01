//
//  PopupOneButtonView.swift
//  Teams
//
//  Created by JinwooLee on 7/1/24.
//

import ComposableArchitecture
import SwiftUI


struct PopupOneButtonView: View {
    @Perception.Bindable var store : StoreOf<WorkspaceCoordinator>
    let action : WorkspaceCoordinator.State.CustomPopup
    
    var body: some View {
        VStack(spacing : 10) {
            
            actionView(for: action)
            
            HStack {
                Button("취소") {
                    store.send(.dismissPopupView)
                }
                .foregroundStyle(.brandWhite)
                .frame(width: 152, height: 44)
                .title2()
                .background(.brandInActive)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Button(actionButtonTitle(for: action)) {
                    handleAction(for: action)
                }
                .foregroundStyle(.brandWhite)
                .frame(width: 152, height: 44)
                .title2()
                .background(.brandGreen)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 15)
        }
        .padding()
        .background(Color.white.cornerRadius(16))
        .padding(.horizontal, 16)
        
    }
    
    @ViewBuilder
    private func actionView(for action: WorkspaceCoordinator.State.CustomPopup) -> some View {
        switch action {
        case .workspaceExit:
            Text("Workspace Exit")
        case .workspaceExitManager:
            Text("Workspace Exit Manager")
        case .workspaceRemove(let titleText, let bodyText, let buttonTitle):
            VStack {
                Text(titleText)
                    .title2()
                Text(bodyText)
                    .multilineTextAlignment(.center)
                    .bodyRegular()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func actionButtonTitle(for action: WorkspaceCoordinator.State.CustomPopup) -> String {
        switch action {
        case .workspaceExit:
            return "Exit"
        case .workspaceExitManager:
            return "Exit Manager"
        case .workspaceRemove(_, _, let buttonTitle):
            return buttonTitle
        }
    }

    private func handleAction(for action: WorkspaceCoordinator.State.CustomPopup) {
        switch action {
        case .workspaceExit, .workspaceExitManager, .workspaceRemove:
            store.send(.workspaceRemove)
        }
    }
}



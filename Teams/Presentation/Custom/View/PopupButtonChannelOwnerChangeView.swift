//
//  PopupButtonChannelOwnerChangeView.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import ComposableArchitecture
import SwiftUI


struct PopupButtonChannelOwnerChangeView: View {
    @Perception.Bindable var store : StoreOf<ChannelOwnerChangeFeature>
    let action : ChannelOwnerChangeFeature.State.CustomPopup
    
    var body: some View {
        VStack(spacing : 10) {
            
            actionView(for: action)
            
            if actionButtonType(for:action){
                HStack {
                    Button("취소") {
                        store.send(.popup(.dismissPopupView))
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
            } else {
                HStack {
                    Button(actionButtonTitle(for: action)) {
                        store.send(.popup(.dismissPopupViewWithError))
                    }
                    .foregroundStyle(.brandWhite)
                    .frame(width: 312, height: 44)
                    .title2()
                    .background(.brandGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 15)
            }
            

        }
        .padding()
        .background(Color.white.cornerRadius(16))
        .padding(.horizontal, 16)
        
    }
    
    @ViewBuilder
    private func actionView(for action: ChannelOwnerChangeFeature.State.CustomPopup) -> some View {
        switch action {
        case let .channelOwnerChange(titleText, bodyText, _, _, _, _):
            alertText(titleText, bodyText)
        }
    }

    private func actionButtonTitle(for action: ChannelOwnerChangeFeature.State.CustomPopup) -> String {
        switch action {
        case let .channelOwnerChange(_, _, buttonTitle, _, _, _):
            return buttonTitle
        }
    }
    
    private func actionButtonType(for action: ChannelOwnerChangeFeature.State.CustomPopup) -> Bool {
        switch action {
        case let .channelOwnerChange(_, _, _, _, _,type):
            return type
        }
    }

    private func handleAction(for action: ChannelOwnerChangeFeature.State.CustomPopup) {
        switch action {
        case let .channelOwnerChange(_,_,_,workspace,channel,_):
//            store.send(.popup(.channelRemove(workspace: workspace, channel: channel)))
            break
        }
        
    }
    
    private func alertText(_ titleText: String, _ bodyText: String) -> VStack<TupleView<(some View, some View)>> {
        return VStack(spacing : 10) {
            Text(titleText)
                .title2()
            Text(bodyText)
                .multilineTextAlignment(.center)
                .bodyRegular()
                .foregroundStyle(.secondary)
        }
    }
    
}

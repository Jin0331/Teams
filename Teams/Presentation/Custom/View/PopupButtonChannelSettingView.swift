//
//  PopupButtonChannelSettingView.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import ComposableArchitecture
import SwiftUI


struct PopupButtonChannelSettingView: View {
    @Perception.Bindable var store : StoreOf<ChannelSettingFeature>
    let action : ChannelSettingFeature.CustomPopup
    
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
                        store.send(.popup(.dismissPopupView))
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
    private func actionView(for action: ChannelSettingFeature.CustomPopup) -> some View {
        if case let .channelRemove(titleText, bodyText, _, _, _, _) = action {
            alertText(titleText, bodyText)
        } else if case let .channelExit(titleText, bodyText, _, _, _, _) = action {
            alertText(titleText, bodyText)
        }
    }

    private func actionButtonTitle(for action: ChannelSettingFeature.CustomPopup) -> String {
        switch action {
        case let .channelRemove(_, _, buttonTitle, _, _, _), let .channelExit(_, _, buttonTitle, _, _, _):
            return buttonTitle
        default :
            return ""
        }
    }
    
    private func actionButtonType(for action: ChannelSettingFeature.CustomPopup) -> Bool {
        switch action {
        case let .channelRemove(_, _, _, _, _,type), let .channelExit(_, _, _, _, _,type):
            return type
        default :
            return false
        }
    }

    private func handleAction(for action: ChannelSettingFeature.CustomPopup) {
        switch action {
        case let .channelRemove(_,_,_,workspace,channel,_):
            store.send(.popup(.channelRemove(workspace: workspace, channel: channel)))
        case let .channelExit(_,_,_,workspace,channel,_):
            store.send(.popup(.channelExit(workspace: workspace, channel: channel)))
        default:
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

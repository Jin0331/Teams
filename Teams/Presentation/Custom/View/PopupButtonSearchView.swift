//
//  PopupButtonSearchView.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import ComposableArchitecture
import SwiftUI

struct PopupButtonSearchView: View {
    @Perception.Bindable var store : StoreOf<SearchFeature>
    let action : SearchFeature.CustomPopup
    
    var body: some View {
        VStack(spacing : 10) {
            
            actionView(for: action)
            
            if actionButtonType(for:action){
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
            } else {
                HStack {
                    Button(actionButtonTitle(for: action)) {
                        store.send(.dismissPopupView)
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
    private func actionView(for action: SearchFeature.CustomPopup) -> some View {
        switch action {
        case let .channelEnter(titleText, bodyText, _, _, _):
            alertText(titleText, bodyText)
        }
    }

    private func actionButtonTitle(for action: SearchFeature.CustomPopup) -> String {
        switch action {
        case let .channelEnter(_, _, buttonTitle, _, _):
            return buttonTitle
        }
    }
    
    private func actionButtonType(for action: SearchFeature.CustomPopup) -> Bool {
        switch action {
        case let .channelEnter(_, _, _, _, type):
            return type
        }
    }

    private func handleAction(for action: SearchFeature.CustomPopup) {
        switch action {
        case let .channelEnter(_,_,_,channelID, _):
            store.send(.buttonTapped(.channelEnter(channelID)))
        default :
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


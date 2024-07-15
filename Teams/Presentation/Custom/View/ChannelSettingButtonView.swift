//
//  ChannelSettingButtonView.swift
//  Teams
//
//  Created by JinwooLee on 7/16/24.
//

import SwiftUI
import ComposableArchitecture

struct ChannelSettingButtonView: View {
    
    let store : StoreOf<ChannelSettingFeature>
    
    var body: some View {
        
        WithPerceptionTracking {
            if store.channelCurrent!.ownerID == UserDefaultManager.shared.userId {
                Image(.channelEdit)
                    .asButton {
                        store.send(.channelEditButtonTapped)
                    }
                
                Image(.channelExit)
                    .asButton {
                        store.send(.channelExitButtonTapped)
                    }
                Image(.channerOwner)
                    .asButton {
                        store.send(.channelOwnerButtonTapped)
                    }
                Image(.channelDelete)
                    .asButton {
                        store.send(.channelRemoveButtonTapped)
                    }
            } else {
                Image(.channelExit)
                    .asButton {
                        store.send(.channelExitButtonTapped)
                    }
            }
        }
    }
}

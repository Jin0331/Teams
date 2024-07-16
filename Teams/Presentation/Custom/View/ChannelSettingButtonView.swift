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
                        store.send(.buttonTapped(.channelEditButtonTapped))
                    }
                
                Image(.channelExit)
                    .asButton {
                        store.send(.buttonTapped(.channelExitButtonTapped))
                    }
                Image(.channerOwner)
                    .asButton {
                        store.send(.buttonTapped(.channelOwnerButtonTapped))
                    }
                Image(.channelDelete)
                    .asButton {
                        store.send(.buttonTapped(.channelRemoveButtonTapped))
                    }
            } else {
                Image(.channelExit)
                    .asButton {
                        store.send(.buttonTapped(.channelExitButtonTapped))
                    }
            }
        }
    }
}

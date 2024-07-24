//
//  ChannelScreen.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import Foundation
import ComposableArchitecture

@Reducer(state: .equatable)
enum ChannelScreen {
    case add(ChannelAddFeature)
    case search(ChannelSearchFeature)
    case chat(ChannelChatFeature)
    case setting(ChannelSettingFeature)
    case owner(ChannelOwnerChangeFeature)
}

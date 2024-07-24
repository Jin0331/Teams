//
//  SearchScreen.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import ComposableArchitecture
import Foundation

@Reducer(state: .equatable)
enum SearchScreen {
    case search(SearchFeature)
    case channel(ChannelCoordinator)
    case dmChat(DMChatFeature)
}


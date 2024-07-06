//
//  HomeScreen.swift
//  Teams
//
//  Created by JinwooLee on 7/6/24.
//

import ComposableArchitecture
import Foundation

@Reducer(state: .equatable)
enum HomeScreen {
    case home(HomeFeature)
    case channelAdd(ChannelAddFeature)
}

//
//  ChannelSearchFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/7/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ChannelSearchFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelList : ChannelList = []
    }
    
    enum Action : Equatable {
        case dismiss
        case onAppear
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
            default :
                return .none
            }
        }
    }
}

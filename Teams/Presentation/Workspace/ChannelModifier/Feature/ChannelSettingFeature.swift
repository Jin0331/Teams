//
//  ChannelSettingFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/15/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct ChannelSettingFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var workspaceCurrent : Workspace?
        var channelCurrent : Channel?
    }
    
    enum Action {
        case onAppear
        case goBack
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .onAppear:
                
                print(state.workspaceCurrent, state.channelCurrent)
                
                return .none
                
            default :
                return .none
            }
        }
    }
}

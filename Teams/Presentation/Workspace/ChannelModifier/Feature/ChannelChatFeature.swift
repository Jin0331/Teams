//
//  ChannelChatFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/9/24.
//

import ComposableArchitecture
import Foundation
import Alamofire

@Reducer
struct ChannelChatFeature {
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        
    }
    
    enum Action  {
        case onAppear
    }
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear :
                print("hi chat view")
                return .none
            }
        }
    }
    
}

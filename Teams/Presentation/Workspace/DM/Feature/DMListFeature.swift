//
//  DMListFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import Foundation
import ComposableArchitecture

@Reducer
struct DMListFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentWorkspace : Workspace?
    }
    
    enum Action {
        
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some ReducerOf<Self> {
        
        Reduce<State, Action> { state, action in
            
            switch action {
                
            }
        }
    }
}

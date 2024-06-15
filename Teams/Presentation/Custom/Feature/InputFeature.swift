//
//  InputFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/10/24.
//

import ComposableArchitecture
import Foundation

@Reducer
struct InputFeature {
    
    @ObservableState
    struct State: Equatable { }
    
    enum Action {
        case emailValidationButtonTapped
    }
    
    @Dependency(\.networkManager) var networkManager
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .emailValidationButtonTapped:
            
            return .none
        }
        
    }
}

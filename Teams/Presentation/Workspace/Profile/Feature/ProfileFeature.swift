//
//  ProfileFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/22/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
    }
    
    enum Action {
        case onAppear
        case goBack
        case networkResponse(NetworkResponse)
        case buttonTapped(ButtonTapped)
    }
    
    enum ButtonTapped {
    }
    
    enum NetworkResponse {
    }
    
    @Dependency(\.networkManager) var networkManager
    
    var body : some Reducer<State, Action> {
        
        Reduce { state, action in
            
            switch action {
            
            case .onAppear :
                
                print("hihihi")
                
                return .none
            
            default :
                return .none
                
            }
        }
    }
}

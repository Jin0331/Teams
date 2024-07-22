//
//  ProfileEditFeature.swift
//  Teams
//
//  Created by JinwooLee on 7/23/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ProfileEditFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var currentProfile : Profile
        var viewType : viewState
    }
    
    enum Action {
        case onAppear
        case goBack
    }
    
    @Dependency(\.networkManager) var networkManager
    @Dependency(\.utilitiesFunction) var utilitiesFunction
    
    var body : some Reducer<State, Action> {
        
        Reduce { state, action in
            switch action {
                
            default :
                return .none
            }
        }
    }
}

extension ProfileEditFeature {
    enum viewState  {
        case nickname
        case phonenumber
    }
}

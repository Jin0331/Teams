//
//  HomeInitialFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/19/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeInitialFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var nickname : String
    }
    
    enum Action {
        case createWorkspaceTapped
        case goToHomeView
    }
}

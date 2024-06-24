//
//  SideMenuFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI


@Reducer
struct SideMenuFeature {
    @ObservableState
    struct State : Equatable {
        
    }
    
    enum Action {
        case createWorkspaceTapped
    }
}

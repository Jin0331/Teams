//
//  HomeEmptyFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/17/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeEmptyFeature {
    
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        var profileImage : URL?
    }
    
    enum Action {
        case createWorkspaceTapped
        case profileButtonTapped
        case openSideMenu
        case closeSideMenu
    }
}

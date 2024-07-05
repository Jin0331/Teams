//
//  HomeFeature.swift
//  Teams
//
//  Created by JinwooLee on 6/11/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct HomeFeature {
    @ObservableState
    struct State : Equatable {
        let id = UUID()
        let workspaceCurrent : Workspace?
    }

    enum Action {
        case openSideMenu
        case closeSideMenu
    }
}

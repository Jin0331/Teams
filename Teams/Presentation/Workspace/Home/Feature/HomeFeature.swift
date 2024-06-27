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
    }

    enum Action {
        case openSideMenu
        case closeSideMenu
    }
}

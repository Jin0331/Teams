//
//  HomeEmptyViewCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/20/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state : .equatable)
enum HomeEmptyScreen {
    case emptyView(HomeEmptyFeature)
}

struct HomeEmptyViewCoordinatorView : View {
    let store : StoreOf<HomeEmptyViewCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .emptyView(store):
                HomeEmptyView(store: store)
            }
        }
    }
    
}

@Reducer
struct HomeEmptyViewCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(routes: [.root(.emptyView(.init()))])
        var routes : [Route<HomeEmptyScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<HomeEmptyScreen>)
    }
}

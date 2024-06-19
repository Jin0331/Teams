//
//  HomeInitialCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/19/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state: .equatable)
enum HomeInitialScreen {
    case initial(HomeInitialFeature)
}

struct HomeInitialCoordinatorView : View {
    let store : StoreOf<HomeInitialCoordinator>
    
    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .initial(store):
                HomeInitialView(store: store)
            }
        }
    }
}

@Reducer
struct HomeInitialCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(nickname : String = "") -> Self {
            Self(routes: [.root(.initial(.init(nickname: nickname)))])
        }
        
        var routes : [Route<HomeInitialScreen.State>]
    }
    
    enum Action {
        case router(IndexedRouterActionOf<HomeInitialScreen>)
    }
}

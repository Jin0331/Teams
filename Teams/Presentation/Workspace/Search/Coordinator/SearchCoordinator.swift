//
//  SearchCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 7/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct SearchCoordinatorView : View {
    let store : StoreOf<SearchCoordinator>
    
    var body : some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .search(store):
                SearchView(store: store)
            }
        }
    }
}

@Reducer
struct SearchCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(currentWorkspace: Workspace? = nil) -> Self {
            Self(
                routes: [.root(.search(.init(currentWorkspace: currentWorkspace)), embedInNavigationView: true)],
                currentWorkspace: currentWorkspace
            )
        }
        var routes: IdentifiedArrayOf<Route<SearchScreen.State>>
        var currentWorkspace : Workspace?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<SearchScreen>)
    }
    
    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}

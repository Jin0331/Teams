//
//  HomeCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

@Reducer(state: .equatable)
enum HomeScreen {
    case home(HomeFeature)
}

struct HomeCoordinatorView : View {
    let store : StoreOf<HomeCoordinator>

    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .home(store):
                HomeView(store: store)
            }
        }
    }


}

@Reducer
struct HomeCoordinator {
    @ObservableState
    struct State : Equatable {
        static let initialState = State(routes: [.root(.home(.init()), embedInNavigationView: true)])
        var routes : [Route<HomeScreen.State>]
    }

    enum Action {
        case router(IndexedRouterActionOf<HomeScreen>)
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

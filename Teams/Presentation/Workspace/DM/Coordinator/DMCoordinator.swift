//
//  DMCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 7/17/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct DMCoordinatorView : View {
    let store : StoreOf<DMCoordinator>
    
    var body : some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .dmList(store):
                DMListView(store: store)
            }
        }
    }
}


@Reducer
struct DMCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(currentWorkspace: Workspace? = nil) -> Self {
            Self(
                routes: [.root(.dmList(.init(currentWorkspace: currentWorkspace)), embedInNavigationView: true)],
                currentWorkspace: currentWorkspace
            )
        }
        var routes: IdentifiedArrayOf<Route<DMScreen.State>>
        var currentWorkspace : Workspace?
    }
    
    enum Action {
        case router(IdentifiedRouterActionOf<DMScreen>)
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

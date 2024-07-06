//
//  HomeCoordinator.swift
//  Teams
//
//  Created by JinwooLee on 6/24/24.
//

import ComposableArchitecture
import SwiftUI
import TCACoordinators

struct HomeCoordinatorView : View {
    let store : StoreOf<HomeCoordinator>

    var body: some View {
        TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
            switch screen.case {
            case let .home(store):
                HomeView(store: store)
            case let .channelAdd(store):
                ChannelAddView(store: store)
            }
        }
    }


}

@Reducer
struct HomeCoordinator {
    @ObservableState
    struct State : Equatable {
        static func initialState(workspaceCurrent: Workspace? = nil) -> Self {
            Self(
                routes: [.root(.home(.init(workspaceCurrent: workspaceCurrent)))],
                currentWorkspace: workspaceCurrent
            )
        }
        var routes: IdentifiedArrayOf<Route<HomeScreen.State>>
        var currentWorkspace : Workspace?
    }

    enum Action {
        case router(IdentifiedRouterActionOf<HomeScreen>)
    }

    var body : some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .router(.routeAction(_, action: .home(.channelCreateButtonTapped))):
                state.routes.presentSheet(.channelAdd(.init(currentWorkspace: state.currentWorkspace)))
                
            case .router(.routeAction(_, action: .channelAdd(.dismiss))):
                state.routes.dismiss()
                
            case .router(.routeAction(_, action: .channelAdd(.createChannelComplete))):
                return .send(.router(.routeAction(id: .home, action: .home(.onAppear))))
                
            default :
                break
            }
            return .none
        }
        .forEachRoute(\.routes, action: \.router)
    }
}
